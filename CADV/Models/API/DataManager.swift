//
//  DataManager.swift
//  CADV
//
//  Created by Misha Vakhrushin on 23.12.2024.
//

import SwiftUI


@MainActor
class DataManager: ObservableObject {
    static var shared = DataManager()
    init(){}
    
    @Published var urlEntities: URLEntities = URLEntities()
    @Published var isAnalyticsLoaded: Bool = false
    
    func loadAnalyticsPage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnalyticsLoaded = true
        }
    }
    
    func fetchData(){
        Task{
            await   fetchProfileData()
            await   fetchMain()
            await   fetchTracker()
            await   fetchMore()
            URLElements.shared.fetchCurrency()
            URLElements.shared.fetchTokenData()
            self.urlEntities.getGroupedTransactions()
        }
    }
    
    func updateProfileData() {
        Task{
            await fetchProfileData()
        }
    }
    
    func updateAnalyticsPage(){
        Task{
            await   fetchTracker()
            await   fetchMore()
        }
    }
    
    func fetchMain() async{
        do{
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/analytics?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            switch response["status_code"] as? Int {
            case 200:
                guard let analytics = response["analytics"] as? [String: Any],
                      let incomeArray = analytics["income"] as? [[String: Any]],
                      let expenseArray = analytics["expense"] as? [[String: Any]],
                      let wealthFundArray = analytics["wealth_fund"] as? [[String: Any]] else {
                    return
                }
                do{
                    let transactionsArray = incomeArray + expenseArray + wealthFundArray
                    let trnsactionsData = try JSONSerialization.data(withJSONObject: transactionsArray, options: [])
                    let transactions = try JSONDecoder().decode([CategorizedTransaction].self, from: trnsactionsData)
                    for transaction in transactions {
                        Logger.shared.log(.info, "Transaction: \(transaction)")
                    }
                    
                    self.urlEntities.categorizedTransactions = transactions
                }catch{
                    Logger.shared.log(.error, "Error decoding transactions: \(error)")
                }
            default:
                Logger.shared.log(.error, "Failed to fetch goals.")
            }
        }catch let error{
            Logger.shared.log(.error, error)
        }
    }
    
    func fetchTracker() async{
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/tracker?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            switch response["status_code"] as? Int {
            case 200:
                guard
                    let tracker = response["tracker"] as? [String: Any],
                    let goalArray = tracker["goal"] as? [[String: Any]]
                else {
                    Logger.shared.log(.warning, "Error: Could not find or parse 'goal' as an array of dictionaries")
                    return
                }
                do {
                    let newGoalsData = try JSONSerialization.data(withJSONObject: goalArray, options: [])
                    let newGoals = try JSONDecoder().decode([Goal].self, from: newGoalsData)
                    
                    self.urlEntities.goals = newGoals
                } catch {

                }
            default:
                Logger.shared.log(.error, "Failed to fetch goals.")
            }
        }catch let error{
            Logger.shared.log(.error, error)
        }
        
    }
    
    func fetchProfileData() async{
        do{
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile",
                method: "GET",
                needsAuthorization: true
            )
            switch response["status_code"] as? Int {
            case 200:
                guard let profileData = try? JSONSerialization.data(withJSONObject: response["profile"] ?? [:], options: []) else {
                    Logger.shared.log(.error, "Error: Could not serialize profile data")
                    return
                }
                do {
                    let profile = try JSONDecoder().decode(ProfileInfo.self, from: profileData)
                    
                    self.urlEntities.profile = profile
                } catch {
                    Logger.shared.log(.error, "Error decoding profile: \(error)")
                }
            default:
                let errorMessage = response["error"] as? String
                Logger.shared.log(.error, "Error: \(errorMessage ?? "Unknown error case")")
            }
        }catch let error{
            Logger.shared.log(.error, error)
        }
    }
    
    func createSubscription() async{
        let parameters = [
            "end_date": "20-01-2025",
            "is_active": true,
            "start_date": "\(Date().formatted(.iso8601))",
            "user_id": ""
        ] as [String : Any]
        do {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/settings/subscription",
                method: "POST",
                parameters: parameters,
                needsAuthorization: true
            )
            switch response["status_code"] as? Int {
            case 200:
                Logger.shared.log(.info, response["message"] as Any)
            default:
                let errorMessage = response["error"] as? String
                Logger.shared.log(.error, "Error: \(errorMessage ?? "Unknown error case")")
            }
        }catch let error{
            Logger.shared.log(.error, error)
        }
    }
    
    func fetchMore() async {
        do {
            
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/more",
                method: "GET",
                needsAuthorization: true
            )
            
            switch response["status_code"] as? Int {
            case 200:
                guard let moreData = response["more"] as? [String: Any] else {
                    Logger.shared.log(.error, "Error: Could not extract 'more' data")
                    return
                }
                
                guard let appData = moreData["app"] as? [String: Any] else {
                    Logger.shared.log(.error, "Error: Could not extract 'app' data")
                    return
                }
                
                Logger.shared.log(.info, "appData: \(appData)")
                
                guard let connectedAccountsDict = appData["connected_accounts"] as? [String: Any] else {
                    Logger.shared.log(.error, "Error: Could not extract 'connected_accounts' data")
                    return
                }
                
                var categoryAccountsMap: [Int: [BankAccount]] = [:]
                
                for (key, accountsArray) in connectedAccountsDict {
                    guard let accountsArray = accountsArray as? [[String: Any]] else {
                        Logger.shared.log(.error, "Error: Invalid account data for key \(key)")
                        continue
                    }

                    guard let category = Int(key) else {
                        Logger.shared.log(.error, "Error: Invalid category key \(key)")
                        continue
                    }

                    var bankAccountsMap: [Int: BankAccount] = [:]

                    for accountData in accountsArray {
                        guard let bankID = accountData["bank_id"] as? Int ?? Int(accountData["bank_id"] as? String ?? ""),
                              let accountNumber = accountData["account_number"] as? String,
                              let accountState = accountData["account_state"] as? Double,
                              let accountType = accountData["account_type"] as? String else {
                            Logger.shared.log(.error, "Error: Invalid account data")
                            Logger.shared.log(.info, accountData)
                            continue
                        }

                        let accountName = accountData["account_name"] as? String ?? "Unknown"
                        let accountCurrency = (accountData["account_currency"] as? String)?.isEmpty == true ? "RUB" : accountData["account_currency"] as? String ?? "RUB"

                        let subAccount = SubAccount(
                            number: accountNumber,
                            name: accountName,
                            totalAmount: accountState,
                            currency: CurrencyType(rawValue: accountCurrency) ?? .ruble
                        )

                        if var bankAccount = bankAccountsMap[bankID] {
                            bankAccount.subAccounts.append(subAccount)
                            bankAccount.totalAmount += subAccount.totalAmount
                            bankAccountsMap[bankID] = bankAccount
                        } else {
                            let newBankAccount = BankAccount(
                                bankID: bankID,
                                totalAmount: subAccount.totalAmount,
                                name: accountType,
                                subAccounts: [subAccount]
                            )
                            bankAccountsMap[bankID] = newBankAccount
                        }
                    }

                    categoryAccountsMap[category] = Array(bankAccountsMap.values)
                }
                Logger.shared.log(.info, "Data fetched successfully. Data: \(self.urlEntities.bankAccounts)")
                
            default:
                let errorMessage = response["error"] as? String
                Logger.shared.log(.error, "Error: \(errorMessage ?? "Unknown error case")")
            }
        } catch {
            Logger.shared.log(.error, "Error fetching data: \(error)")
        }
    }}
