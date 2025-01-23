//
//  URLElements.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.12.2024.
//

import Foundation
import RealmSwift
import SwiftyJSON

struct URLElements {
    var urlString: String = "https://cshdvsr.com/api/"
    var tokenData: TokenData
    var currency: String = "RUB"
    
    var savedCategories: Results<CategoryEntity> {
        Logger.shared.log(.warning,"Realm trying at \(Thread.current)")
        return RealmManager.shared.realm.objects(CategoryEntity.self)
    }

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
        var urlString = self.urlString + endpoint
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
        Logger.shared.log(.warning, tokenData)
        var headers = [String: String]()

        if needsAuthorization {
            headers["Authorization"] = "Bearer " + tokenData.accessToken
        }
        if needsCurrency {
            headers["X-Currency"] = self.currency
        }

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        if endpoint.contains("/auth") {
            headers["X-Device-ID"] = getDeviceIdentifier()
        }

        return headers
    }

    mutating func fetchCurrency() {
        if let currencyEntity = RealmManager.shared.realm.objects(CurrencyEntity.self).first {
            self.currency = currencyEntity.currency
        }
    }

    mutating func fetchTokenData() {
        if let tokenEntity = RealmManager.shared.realm.objects(TokenEntity.self).first {
            self.tokenData = TokenData(
                accessToken: tokenEntity.accessToken,
                refreshToken: tokenEntity.refreshToken,
                accessTokenExpiresAt: tokenEntity.accessTokenExpiresAt,
                refreshTokenExpiresAt: tokenEntity.refreshTokenExpiresAt
            )
        }
    }

    func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
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
                parameters: [
                    "refresh_token": self.tokenData.refreshToken,
                    "X-Device-ID": getDeviceIdentifier()
                ]
            )

            let json = JSON(response)

            if json["status_code"].intValue == 200 {
                let newToken = json["access_token"].stringValue
                let newRefreshToken = json["refresh_token"].stringValue

                saveNewTokens(token: newToken, refreshToken: newRefreshToken)

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

    mutating func saveTokenData(responseObject: [String: Any]) {
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

        let tokenEntity = TokenEntity()
        tokenEntity.deviceID = deviceID
        tokenEntity.accessToken = accessToken
        tokenEntity.refreshToken = refreshToken
        tokenEntity.accessTokenExpiresAt = Date().addingTimeInterval(Double(accessTokenLifeTime))
        tokenEntity.refreshTokenExpiresAt = Date(timeIntervalSince1970: Double(refreshTokenExpiresAt))

        do {
            try RealmManager.shared.realm.write {
                RealmManager.shared.realm.add(tokenEntity, update: .modified)
            }
            Logger.shared.log(.info, "Token data saved successfully.")
            self.tokenData = TokenData(from: tokenEntity)
        } catch {
            Logger.shared.log(.error, "Failed to save token data: \(error.localizedDescription)")
        }
    }

    func deleteAllEntities() {
        do {
            try RealmManager.shared.realm.write {
                RealmManager.shared.realm.deleteAll()
            }
            Logger.shared.log(.info, "All entities deleted successfully.")
        } catch {
            Logger.shared.log(.error, "Failed to delete entities: \(error.localizedDescription)")
        }
    }

    func saveNewTokens(token: String, refreshToken: String) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.saveNewTokens(token: token, refreshToken: refreshToken)
            }
            return
        }
        
        if let tokenEntity = RealmManager.shared.realm.objects(TokenEntity.self).first {
            do {
                try RealmManager.shared.realm.write {
                    tokenEntity.accessToken = token
                    tokenEntity.refreshToken = refreshToken
                    tokenEntity.accessTokenExpiresAt = Date().addingTimeInterval(60)
                }
            } catch {
                Logger.shared.log(.error, "Failed to save refreshed token: \(error.localizedDescription)")
            }
        }
    }
}
