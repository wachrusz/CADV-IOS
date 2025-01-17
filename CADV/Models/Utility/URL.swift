//
//  URL.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.12.2024.
//
import Foundation
import CoreData
import SwiftyJSON

struct TokenData{
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresAt: Date = Date().addingTimeInterval(900)
    var refreshTokenExpiresAt: Date
}

extension TokenData {
    init(from entity: AccessEntity) {
        self.accessToken = entity.accessToken ?? ""
        self.refreshToken = entity.refreshToken ?? ""
        self.accessTokenExpiresAt = entity.accessTokenExpiresAt ?? Date()
        self.refreshTokenExpiresAt = Date().addingTimeInterval(TimeInterval(entity.refreshTokenLifeTime))
    }
}

struct URLElements {
    var urlString: String = "https://cshdvsr.com/api/"
    var tokenData: TokenData
    var viewCtx: NSManagedObjectContext
    var currency: String = "RUB"
    
    mutating func updateTokenData(_ newTokenData: TokenData) {
        tokenData = newTokenData
    }
    
    func fetchData(
        endpoint: String,
        method: String = "POST",
        parameters: [String: Any] = [:],
        retryAttempts: Int = 1,
        needsAuthorization: Bool = false,
        needsCurrency: Bool = false
    ) async throws -> [String: Any] {
        return try await abstractFetchData(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            retryAttempts: retryAttempts,
            needsAuthorization: needsAuthorization,
            needsCurrency: needsCurrency
        )
    }
    
    func abstractFetchData(
        endpoint: String,
        method: String = "POST",
        parameters: [String: Any] = [:],
        retryAttempts: Int = 1,
        needsAuthorization: Bool = false,
        needsCurrency: Bool = false
    ) async throws -> [String: Any] {
        Logger.shared.log(.warning, "-------------------------------------")
        var urlString =  self.urlString + endpoint
        Logger.shared.log(.warning, "Sending request to \(urlString)")
        
        if method == "GET", !parameters.isEmpty {
            let queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            var urlComponents = URLComponents(string: urlString)
            urlComponents?.queryItems = queryItems
            urlString = urlComponents?.url?.absoluteString ?? urlString
        }
        
        guard let url = URL(string: urlString) else {
            Logger.shared.log(.error, NSError(domain: "abstractFetchData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            throw NSError(domain: "abstractFetchData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        
        let headers = self.prepareHeaders(
            with: tokenData,
            needsAuthorization: needsAuthorization,
            needsCurrency: needsCurrency,
            endpoint: endpoint
        )
        
        Logger.shared.log(.warning, headers)
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if method == "POST" || method == "PUT" {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                Logger.shared.log(.error, NSError(domain: "abstractFetchData", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"]))
                throw NSError(domain: "abstractFetchData", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"])
            }
        }
        
        let session = URLSession(
            configuration: .default,
            delegate: URLSessionHelper.shared,
            delegateQueue: nil
        )
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "abstractFetchData", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            
            Logger.shared.log(.info, responseObject)
            
            switch httpResponse.statusCode {
            case 401:
                if retryAttempts > 0, headers["Authorization"] != nil {
                    Logger.shared.log(.warning, "Received 401, attempting to refresh token...")
                    let success = await withCheckedContinuation { continuation in
                        refreshTokenIfNeeded() { result in
                            continuation.resume(returning: result)
                        }
                    }
                    
                    if success {
                        Logger.shared.log(.info, "Token refreshed successfully, retrying request...")
                        var newHeaders = headers
                        newHeaders["Authorization"] = self.tokenData.accessToken
                        return try await abstractFetchData(
                            endpoint: endpoint,
                            method: method,
                            parameters: parameters,
                            retryAttempts: retryAttempts - 1,
                            needsAuthorization: needsAuthorization
                        )
                    } else {
                        Logger.shared.log(.error, "Failed to refresh token, aborting...")
                        throw NSError(domain: "abstractFetchData", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: Token refresh failed"])
                    }
                } else {
                    throw NSError(domain: "abstractFetchData", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
                }
            case 200, 201, 429, 500:
                return responseObject
            default:
                throw NSError(domain: "abstractFetchData", code: httpResponse.statusCode, userInfo: ["response": responseObject])
            }
        } catch {
            throw error
        }
    }
    
    func prepareHeaders(
        with tokenData: TokenData,
        needsAuthorization: Bool,
        needsCurrency: Bool,
        endpoint: String
    ) -> [String: String] {
        var headers = [String: String]()

        if needsAuthorization {
            headers["Authorization"] = "Bearer " + tokenData.accessToken
        }
        if needsCurrency{
            headers["X-Currency"] = self.currency
        }

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        if endpoint.contains("/auth"){
            headers["X-Device-ID"] = getDeviceIdentifier()
        }

        return headers
    }
    
    mutating func fetchCurrency(){
        let fetchRequest: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do{
            let currency = try viewCtx.fetch(fetchRequest)
            if !currency.isEmpty{
                self.currency = currency[0].currency ?? ""
            }
        }catch{
            Logger.shared.log(.error, error)
        }
    }
    
    mutating func fetchTokenData(){
        let fetchRequest: NSFetchRequest<AccessEntity> = AccessEntity.fetchRequest()
        do{
            let dataArr = try viewCtx.fetch(fetchRequest)
            if let data = dataArr.first{
                self.tokenData = TokenData(
                    accessToken: data.accessToken ?? "",
                    refreshToken: data.refreshToken ?? "",
                    refreshTokenExpiresAt: Date().addingTimeInterval(
                        TimeInterval(data.refreshTokenLifeTime)
                    )
                )
            }
            
        }catch{
            Logger.shared.log(.error, (error))
        }
    }
    
    func refreshTokenIfNeeded(
        completion: @escaping (Bool) -> Void
    ) {
        if tokenData.accessTokenExpiresAt < Date(timeIntervalSinceNow: 10) {
            Task {
                let success = await refreshToken()
                completion(success)
            }
        } else {
            completion(true)
        }
    }

    func refreshToken() async -> Bool {
        Logger.shared.log(.warning, "Started refresh")
        
        do {
            let response = try await fetchData(
                endpoint: "v1/auth/refresh",
                method: "POST",
                parameters: ["refresh_token": self.tokenData.refreshToken]
            )
            
            let json = JSON(response)
            
            if json["status_code"].intValue == 200 {
                let newToken = json["access_token"].stringValue
                let newRefreshToken = json["refresh_token"].stringValue
                
                saveNewTokens(token: newToken, refreshToken: newRefreshToken, viewCtx: viewCtx)
                
                Logger.shared.log(.info, "Token refreshed successfully")
                return true
            } else {
                let errorMessage = json.dictionaryObject ?? [:]
                Logger.shared.log(.error, "Error refreshing token: \(errorMessage)")
            }
        } catch {
            Logger.shared.log(.error, "Failed to refresh token: \(error.localizedDescription)")
        }
        
        return false
    }
    //! CORE DATA
    mutating func saveTokenData(responseObject: [String: Any]) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AccessEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewCtx.execute(deleteRequest)
            Logger.shared.log(.info, "Deleted old tokens")
        } catch {
            Logger.shared.log(.error, "Failed to delete old tokens: \(error)")
        }
        
        guard
            let deviceID = responseObject["device_id"] as? String,
            let accessTokenLifeTime = responseObject["access_token_life_time"] as? Int,
            let tokenDetails = responseObject["token_details"] as? [String: Any],
            let accessToken = tokenDetails["access_token"] as? String,
            let refreshToken = tokenDetails["refresh_token"] as? String,
            let refreshTokenExpiresAt = tokenDetails["expires_at"] as? Int64
        else {
            Logger.shared.log(.error, "Error: Missing or incorrect data structure in responseObject.")
            return
        }
        
        let token = AccessEntity(context: viewCtx)
        token.deviceID = deviceID
        token.refreshTokenLifeTime = Int64(30*24*60*60)
        token.accessToken = accessToken
        token.refreshToken = refreshToken
        token.accessTokenExpiresAt = Date().addingTimeInterval(Double(accessTokenLifeTime))
        do {
            try viewCtx.save()
            Logger.shared.log(.info, "Token data saved successfully.")
            self.tokenData = TokenData(from: token)
            Logger.shared.log(.info, self.tokenData)
        } catch {
            Logger.shared.log(.error, "Failed to save token data: \(error.localizedDescription)")
        }
    }
    
    func deleteAllEntities() {
        let persistentStoreCoordinator = self.viewCtx.persistentStoreCoordinator

        do {
            if let entities = persistentStoreCoordinator?.managedObjectModel.entities {
                for entity in entities {
                    if let entityName = entity.name {
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        do {
                            try self.viewCtx.execute(deleteRequest)
                            Logger.shared.log(.warning, "Удалены данные для сущности: \(entityName)")
                        } catch {
                            Logger.shared.log(.error, "Ошибка при удалении данных для сущности \(entityName): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    
    func saveNewTokens(
        token: String,
        refreshToken: String,
        viewCtx: NSManagedObjectContext
    ){
        let fetchRequest: NSFetchRequest<AccessEntity> = AccessEntity.fetchRequest()
        do {
            let tokens = try viewCtx.fetch(fetchRequest)
            if let existingToken = tokens.first {
                existingToken.accessToken = token
                existingToken.refreshToken = refreshToken
                existingToken.accessTokenExpiresAt = Date().addingTimeInterval(60)
                
                try viewCtx.save()
            }
        } catch {
            Logger.shared.log(.error, "Failed to fetch or save refreshed token: \(error.localizedDescription)")
        }
    }

}
