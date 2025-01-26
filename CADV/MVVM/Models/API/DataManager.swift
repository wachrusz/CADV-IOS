//
//  DataManager.swift
//  CADV
//
//  Created by Misha Vakhrushin on 23.12.2024.
//

import SwiftUI
import SwiftyJSON

@MainActor
class DataManager: ObservableObject {
    static var shared = DataManager()
    init() {}
    
    @Published var urlEntities: URLEntities = URLEntities()
    @Published var isAnalyticsLoaded: Bool = false
    
    func loadAnalyticsPage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnalyticsLoaded = true
        }
    }
    
    func fetchData() {
        Task {
            await fetchProfileData()
            await fetchMain()
            await fetchTracker()
            await fetchMore()
            URLElements.shared.fetchCurrency()
            URLElements.shared.fetchTokenData()
            self.urlEntities.getGroupedTransactions()
        }
    }
    
    func updateProfileData() {
        Task {
            await fetchProfileData()
        }
    }
    
    func updateAnalyticsPage() {
        Task {
            await fetchTracker()
            await fetchMore()
        }
    }
    
    func fetchMain() async {
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/analytics?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            let json = JSON(response)
            
            if json["status_code"].intValue == 200 {
                let analytics = json["analytics"]
                let incomeArray = analytics["income"].arrayValue
                let expenseArray = analytics["expense"].arrayValue
                let wealthFundArray = analytics["wealth_fund"].arrayValue
                
                let transactionsArray = incomeArray + expenseArray + wealthFundArray
                let transactions = transactionsArray.compactMap { CategorizedTransaction(json: $0) }
                
                self.urlEntities.categorizedTransactions = transactions
                Logger.shared.log(.info, "Transactions: \(transactions)")
            } else {
                Logger.shared.log(.error, "Failed to fetch analytics.")
            }
        } catch {
            Logger.shared.log(.error, "Error fetching main data: \(error)")
        }
    }
    
    func fetchTracker() async {
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/tracker?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            let json = JSON(response)
            
            if json["status_code"].intValue == 200 {
                let tracker = json["tracker"]
                let goalArray = tracker["goal"].arrayValue
                
                let goals = goalArray.compactMap { Goal(json: $0) }
                self.urlEntities.goals = goals
                Logger.shared.log(.info, "Goals: \(goals)")
            } else {
                Logger.shared.log(.error, "Failed to fetch tracker.")
            }
        } catch {
            Logger.shared.log(.error, "Error fetching tracker: \(error)")
        }
    }
    
    func fetchProfileData() async {
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile",
                method: "GET",
                needsAuthorization: true
            )
            let json = JSON(response)
            
            if json["status_code"].intValue == 200 {
                let profile = ProfileInfo(json: json["profile"])
                self.urlEntities.profile = profile
                Logger.shared.log(.info, "Profile: \(profile)")
            } else {
                Logger.shared.log(.error, "Failed to fetch profile data.")
            }
        } catch {
            Logger.shared.log(.error, "Error fetching profile data: \(error)")
        }
    }
    
    func createSubscription() async {
        let parameters: [String: Any] = [
            "end_date": "20-01-2025",
            "is_active": true,
            "start_date": Date().ISO8601Format(),
            "user_id": ""
        ]
        
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/settings/subscription",
                method: "POST",
                parameters: parameters,
                needsAuthorization: true
            )
            let json = JSON(response)
            
            if json["status_code"].intValue == 200 {
                Logger.shared.log(.info, json["message"].stringValue)
            } else {
                Logger.shared.log(.error, "Error: \(json["error"].stringValue)")
            }
        } catch {
            Logger.shared.log(.error, "Error creating subscription: \(error)")
        }
    }
    
    func fetchMore() async {
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/more",
                method: "GET",
                needsAuthorization: true
            )
            let json = JSON(response)
            
            if json["status_code"].intValue == 200 {
                processConnectedAccounts(json: json)
                let moreData = json["more"]
                let appData = moreData["app"]
                let connectedAccountsDict = appData["connected_accounts"].dictionaryValue
            } else {
                Logger.shared.log(.error, "Error: \(json["error"].stringValue)")
            }
        } catch {
            Logger.shared.log(.error, "Error fetching more data: \(error)")
        }
    }
    
    //MARK: FIX LATER
    func processConnectedAccounts(json: JSON) {
        let moreData = json["more"]
        let appData = moreData["app"]
        let connectedAccounts = appData["connected_accounts"].dictionaryObject
        
        var bankAccountsMap: [Int: BankAccount] = [:]
        
        for value in connectedAccounts ?? [:] {
            guard let bankID = Int(value.key) else {
                Logger.shared.log(.error, "Invalid BankID: \(value.key)")
                continue
            }
            
            let subAccounts = value.value
            
            if let subAccountsArray = subAccounts as? [[String: Any]] {
                Logger.shared.log(.warning, "BankID: \(bankID), subAccounts: \(subAccountsArray)")
                var type = ""
                var subAccountsList: [SubAccount] = []
                
                for subAccountDict in subAccountsArray {
                    guard let number = subAccountDict["account_number"] as? String,
                          let name = subAccountDict["account_name"] as? String,
                          let totalAmount = subAccountDict["account_state"] as? Double,
                          let currencyString = subAccountDict["account_currency"] as? String,
                          let accountTypeString = subAccountDict["account_type"] as? String
                    else {
                        Logger.shared.log(.error, "Invalid SubAccount data for BankID: \(bankID)")
                        continue
                    }
                    
                    let subAccount = SubAccount(
                        number: number,
                        name: name,
                        totalAmount: totalAmount,
                        currency: .ruble
                    )
                    
                    type = accountTypeString
                    
                    subAccountsList.append(subAccount)
                    Logger.shared.log(.warning, "SubAccount: \(subAccount)")
                }
                
                if var bankAccount = bankAccountsMap[bankID] {
                    bankAccount.subAccounts.append(contentsOf: subAccountsList)
                    bankAccountsMap[bankID] = bankAccount
                } else {
                    let bankAccount = BankAccount(
                        bankID: bankID,
                        totalAmount: subAccountsList.reduce(0) { $0 + $1.totalAmount },
                        name: type,
                        subAccounts: subAccountsList
                    )
                    bankAccountsMap[bankID] = bankAccount
                }
            } else {
                Logger.shared.log(.error, "SubAccounts is not an array for BankID: \(bankID)")
            }
        }
        
        var bankAccountsDict: [Int: BankAccounts] = [:]
        for (bankID, bankAccount) in bankAccountsMap {
            bankAccountsDict[bankID] = BankAccounts(Array: [bankAccount], Group: BankAccountsGroup(rawValue: bankAccount.name) ?? .cash, Currency: CurrencyType(rawValue: URLElements.shared.currency) ?? .ruble)
        }
        self.urlEntities.bankAccounts = bankAccountsDict
        
        Logger.shared.log(.warning, "Processed BankAccounts: \(self.urlEntities.bankAccounts)")
    }
}
