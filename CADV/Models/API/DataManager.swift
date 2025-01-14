//
//  DataManager.swift
//  CADV
//
//  Created by Misha Vakhrushin on 23.12.2024.
//

import SwiftUI


@MainActor
class DataManager: ObservableObject {
    @Published var urlEntities: URLEntities = URLEntities()
    @Published var isAnalyticsLoaded: Bool = false
    var urlElements: URLElements?
    
    init(urlElements: URLElements?) {
        self.urlElements = urlElements
    }
    
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
            self.urlElements?.fetchCurrency()
            self.urlElements?.fetchTokenData()
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
            let response = try await self.urlElements?.fetchData(
                endpoint: "v1/profile/analytics?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            switch response?["status_code"] as? Int {
            case 200:
                print(response?["analytics"] as Any)
                guard let analytics = response?["analytics"] as? [String: Any],
                      let incomeArray = analytics["income"] as? [[String: Any]],
                      let expenseArray = analytics["expense"] as? [[String: Any]],
                      let wealthFundArray = analytics["wealth_fund"] as? [[String: Any]] else {
                    print("Error: Could not find or parse 'transactions' as an array of dictionaries")
                    return
                }
                do{
                    let transactionsArray = incomeArray + expenseArray + wealthFundArray
                    let trnsactionsData = try JSONSerialization.data(withJSONObject: transactionsArray, options: [])
                    let transactions = try JSONDecoder().decode([CategorizedTransaction].self, from: trnsactionsData)
                    for transaction in transactions {
                        print("Transaction: \(transaction)")
                    }
                    
                    self.urlEntities.categorizedTransactions = transactions
                }catch{
                    print("Error decoding transactions: \(error)")
                }
            default:
                print("Failed to fetch goals.")
            }
        }catch let error{
            print(error)
        }
    }
    
    func fetchTracker() async{
        do {
            let response = try await self.urlElements?.fetchData(
                endpoint: "v1/profile/tracker?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            switch response?["status_code"] as? Int {
            case 200:
                guard
                    let tracker = response?["tracker"] as? [String: Any],
                    let goalArray = tracker["goal"] as? [[String: Any]]
                else {
                    print("Error: Could not find or parse 'goal' as an array of dictionaries")
                    return
                }
                do {
                    print(tracker)
                    let newGoalsData = try JSONSerialization.data(withJSONObject: goalArray, options: [])
                    let newGoals = try JSONDecoder().decode([Goal].self, from: newGoalsData)
                    
                    self.urlEntities.goals = newGoals
                } catch {

                }
            default:
                print("Failed to fetch goals.")
            }
        }catch let error{
            print(error)
        }
        
    }
    
    func fetchProfileData() async{
        do{
            let response = try await self.urlElements?.fetchData(
                endpoint: "v1/profile",
                method: "GET",
                needsAuthorization: true
            )
            switch response?["status_code"] as? Int {
            case 200:
                print(response ?? [:])
                guard let profileData = try? JSONSerialization.data(withJSONObject: response?["profile"] ?? [:], options: []) else {
                    print("Error: Could not serialize profile data")
                    return
                }
                do {
                    let profile = try JSONDecoder().decode(ProfileInfo.self, from: profileData)
                    
                    self.urlEntities.profile = profile
                } catch {
                    print("Error decoding profile: \(error)")
                }
            default:
                let errorMessage = response?["error"] as? String
                print("Error: \(errorMessage ?? "Unknown error case")")
            }
        }catch let error{
            print(error)
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
            let response = try await self.urlElements?.fetchData(
                endpoint: "v1/settings/subscription",
                method: "POST",
                parameters: parameters,
                needsAuthorization: true
            )
            switch response?["status_code"] as? Int {
            case 200:
                print(response?["message"] as Any)
            default:
                let errorMessage = response?["error"] as? String
                print("Error: \(errorMessage ?? "Unknown error case")")
            }
        }catch let error{
            print(error)
        }
    }
    
    func fetchMore() async {
        do {
            guard let urlElements = self.urlElements else {
                print("Error: urlElements is nil")
                return
            }
            
            let response = try await urlElements.fetchData(
                endpoint: "v1/profile/more",
                method: "GET",
                needsAuthorization: true
            )
            
            switch response["status_code"] as? Int {
            case 200:
                guard let moreData = response["more"] as? [String: Any] else {
                    print("Error: Could not extract 'more' data")
                    return
                }
                
                guard let appData = moreData["app"] as? [String: Any] else {
                    print("Error: Could not extract 'app' data")
                    return
                }
                
                print("appData: \(appData)")
                
                guard let connectedAccountsDict = appData["connected_accounts"] as? [String: Any] else {
                    print("Error: Could not extract 'connected_accounts' data")
                    return
                }
                
                var categoryAccountsMap: [Int: [BankAccount]] = [:]
                
                for (key, accountsArray) in connectedAccountsDict {
                    guard let accountsArray = accountsArray as? [[String: Any]] else {
                        print("Error: Invalid account data for key \(key)")
                        continue
                    }
                    
                    guard let category = Int(key) else {
                        print("Error: Invalid category key \(key)")
                        continue
                    }
                    
                    var bankAccountsMap: [Int: BankAccount] = [:]
                    
                    for accountData in accountsArray {
                        guard let bankID = accountData["bank_id"] as? Int ?? Int(accountData["bank_id"] as? String ?? ""),
                              let accountCurrency = accountData["account_currency"] as? String,
                              let accountNumber = accountData["account_number"] as? String,
                              let accountState = accountData["account_state"] as? Double,
                              let accountType = accountData["account_type"] as? String else {
                            print("Error: Invalid account data")
                            print(accountData)
                            continue
                        }
                        
                        let accountName = accountData["account_name"] as? String ?? "Unknown"
                        
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
                
                for (category, bankAccounts) in categoryAccountsMap {
                    self.urlEntities.bankAccounts[category]?.Array = bankAccounts
                }
                
            default:
                let errorMessage = response["error"] as? String
                print("Error: \(errorMessage ?? "Unknown error case")")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }}
