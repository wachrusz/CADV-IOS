//
//  TabBar.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import SwiftUI
import CoreData

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                selectedTab = 0
            }) {
                VStack(spacing: 5) {
                    Image("TabBarIconMainActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .opacity(selectedTab == 0 ? 1 : 0.5)
                .animation(.easeInOut, value: selectedTab == 0 ? 1 : 0.5)
            }
            
            Button(action: {
                selectedTab = 1
            }) {
                VStack(spacing: 5) {
                    Image("TabBarIconTrackerActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .opacity(selectedTab == 1 ? 1 : 0.5)
                .animation(.easeInOut, value: selectedTab == 1 ? 1 : 0.5)
            }
            
            Button(action: {
                selectedTab = 2
            }) {
                VStack(spacing: 5) {
                    Image("TabBarIconSettingsActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .opacity(selectedTab == 2 ? 1 : 0.5)
                .animation(.easeInOut, value: selectedTab == 2 ? 1 : 0.5)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .frame(height: 65)
        .background(.white)
        .overlay(
            Rectangle()
                .inset(by: 1)
                .stroke(.black, lineWidth: 0.01)
        )
        .navigationBarBackButtonHidden(true)
    }
}

struct TokenData{
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresAt: Date = Date().addingTimeInterval(900)
    var refreshTokenExpiresAt: Date
}

struct TabBarContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State public var tokenData: TokenData = TokenData(
        accessToken: "",
        refreshToken: "",
        refreshTokenExpiresAt: Date()
    )
    @State private var selectedTab = 0
    @State private var isAnalyticsLoaded = false
    @State private var profile: ProfileInfo = test_fetchProfileInfo()
    @State private var categorizedTransactions: [CategorizedTransaction] = []
    @State private var goals: [Goal] = []
    @State private var annualPayments: [AnnualPayment] = []
    @State private var bankAccounts = BankAccounts(Array: [])
    @State private var groupedAndSortedTransactions: [(date: Date, categorizedTransactions: [CategorizedTransaction])] = []
    @State private var currency: String = "RUB"
    
    init(){
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                switch selectedTab {
                case 0:
                    MainPageView(
                        profile: $profile,
                        categorizedTransactions: $categorizedTransactions,
                        tokenData: $tokenData
                    )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .navigationBarBackButtonHidden(true)
                case 1:
                    if isAnalyticsLoaded {
                        AnalyticsPageView(
                            profile: $profile,
                            categorizedTransactions: $categorizedTransactions,
                            goals: $goals,
                            annualPayments: $annualPayments,
                            bankAccounts: $bankAccounts,
                            groupedAndSortedTransactions: $groupedAndSortedTransactions,
                            currency: $currency,
                            tokenData: $tokenData
                        )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color.white.edgesIgnoringSafeArea(.all))
                            .foregroundStyle(.black)
                            .onAppear {
                                loadAnalyticsPage()
                            }
                    }
                case 2:
                    SettingsPageView(
                        profile: $profile,
                        tokenData: $tokenData
                    )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                default:
                    MainPageView(
                        profile: $profile,
                        categorizedTransactions: $categorizedTransactions,
                        tokenData: $tokenData
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
        .colorScheme(.light)
        .onAppear(){
            fetchData()
        }
    }
    
    func loadAnalyticsPage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnalyticsLoaded = true
        }
    }
    
    func fetchTokenData(){
        let fetchRequest: NSFetchRequest<AccessEntity> = AccessEntity.fetchRequest()
        do{
            let dataArr = try viewContext.fetch(fetchRequest)
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
            print(error)
        }
    }
    
    func fetchData(){
        fetchCurrency()
        fetchTokenData()
        fetchProfileData()
        fetchTracker()
        fetchMain()
        
        self.groupedAndSortedTransactions = getGroupedTransactionsAndSortByDate(categorizedTransactions)
        self.groupedAndSortedTransactions = filterTransactions(categorizedTransactions, gns: groupedAndSortedTransactions)
    }
    
    func fetchCurrency(){
        let fetchRequest: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do{
            let currency = try viewContext.fetch(fetchRequest)
            self.currency = currency[0].currency ?? ""
        }catch{
            print(error)
        }
    }
    
    func fetchMain(){
        print("----------------------------------------\nFetchingMain")
            abstractFetchData(
                endpoint: "v1/profile/analytics?limit=20&offset=0",
                method: "GET",
                headers: ["accept" : "application/json", "Authorization" : tokenData.accessToken, "X-Currency": self.currency]
            ){ result in
                switch result {
                case .success(let responseObject):
                    switch responseObject["status_code"] as? Int {
                    case 200:
                        print(responseObject)
                    default:
                        print("Failed to fetch goals.")
                    }
                    
                case .failure(let error):
                    print("Another yet error: \(error)")
                }
            }
        print("----------------------------------------\nFetchingMain")
    }
    
    func fetchTracker(){
        print("----------------------------------------\nFetchingTracker")
            abstractFetchData(
                endpoint: "v1/profile/tracker?limit=20&offset=0",
                method: "GET",
                headers: ["accept" : "application/json", "Authorization" : tokenData.accessToken, "X-Currency": self.currency]
            ){ result in
                switch result {
                case .success(let responseObject):
                    switch responseObject["status_code"] as? Int {
                    case 200:
                        print(responseObject)

                        guard
                            let tracker = responseObject["tracker"] as? [String: Any],
                            let goalArray = tracker["goal"] as? [[String: Any]]
                        else {
                            print("Error: Could not find or parse 'goal' as an array of dictionaries")
                            return
                        }

                        do {
                            let newGoalsData = try JSONSerialization.data(withJSONObject: goalArray, options: [])
                            let newGoals = try JSONDecoder().decode([Goal].self, from: newGoalsData)
                            self.goals = newGoals
                            print("Goals decoded successfully: \(self.goals)")
                        } catch {
                            print("Error decoding goals: \(error)")
                        }

                    default:
                        print("Failed to fetch goals.")
                    }
                    
                case .failure(let error):
                    print("Another yet error: \(error)")
                }
            }
        print("----------------------------------------\nFetchingTracker")
    }
    
    func fetchProfileData() {
        print("----------------------------------------\nProfileFetch")
        abstractFetchData(
            endpoint: "v1/profile",
            method: "GET",
            headers: ["accept" : "application/json", "Authorization": tokenData.accessToken]
        ) { result in
            switch result {
            case .success(let responseObject):
                switch responseObject["status_code"] as? Int {
                case 200:
                    print(responseObject)
                    guard let profileData = try? JSONSerialization.data(withJSONObject: responseObject["profile"] ?? [:], options: []) else {
                        print("Error: Could not serialize profile data")
                        return
                    }
                    
                    do {
                        let profile = try JSONDecoder().decode(ProfileInfo.self, from: profileData)
                        self.profile = profile
                        print("Profile decoded successfully: \(profile)")
                    } catch {
                        print("Error decoding profile: \(error)")
                    }
                case 401:
                    refreshTokenIfNeeded()
                default:
                    let errorMessage = responseObject["error"] as? String
                    print("Error: \(errorMessage ?? "Unknown error case")")
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
        print("----------------------------------------\nProfileFetch")
    }

    
    func refreshTokenIfNeeded() {
        if tokenData.accessTokenExpiresAt < Date(timeIntervalSinceNow: 60){
            refreshToken(tokenData.refreshToken)
        }
    }
    
    func refreshToken(_ refreshToken: String?) {
        print("----------------------------------------\nRefreshingToken")
        
        abstractFetchData(
            endpoint: "v1/auth/refresh",
            method: "POST",
            parameters: ["refresh_token": tokenData.refreshToken],
            headers: ["Content-Type" : "application/json", "Authorization": tokenData.accessToken]
        ) { result in
            switch result {
            case .success(let responseObject):
                switch responseObject["status_code"] as? Int {
                case 200:
                    let newToken = responseObject["access_token"] as? String
                    let newRefreshToken = responseObject["refresh_token"] as? String
                    
                    if let token = newToken, let refreshToken = newRefreshToken {
                        self.saveNewTokens(token: token, refreshToken: refreshToken)
                    }
                default:
                    let errorMessage = responseObject["error"] as? String
                    print("Error: \(errorMessage ?? "Unknown error case")")
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
        print("----------------------------------------\nRefreshingToken")
    }

    func saveNewTokens(token: String, refreshToken: String) {
        print("----------------------------------------\nSavingNewTokens")
        let fetchRequest: NSFetchRequest<AccessEntity> = AccessEntity.fetchRequest()
        do {
            let tokens = try viewContext.fetch(fetchRequest)
            if let existingToken = tokens.first {
                existingToken.accessToken = token
                existingToken.refreshToken = refreshToken
                existingToken.accessTokenExpiresAt = Date().addingTimeInterval(900)
                
                self.tokenData = TokenData(
                    accessToken: token,
                    refreshToken: refreshToken,
                    refreshTokenExpiresAt: Date().addingTimeInterval(
                        TimeInterval(existingToken.refreshTokenLifeTime)
                    )
                )
                
                try viewContext.save()
                print("Token refreshed and saved.")
            }
        } catch {
            print("Failed to fetch or save refreshed token: \(error.localizedDescription)")
        }
        print("----------------------------------------\nSavingNewTokens")
    }
    
    func createSubscription() {
        print("----------------------------------------\nCreatingSubscription")
        let parameters = [
            "end_date": "20-01-2025",
            "is_active": true,
            "start_date": "\(Date().formatted(.iso8601))",
            "user_id": ""
        ] as [String : Any]
        
        abstractFetchData(
            endpoint: "v1/settings/subscription",
            method: "POST",
            parameters: parameters,
            headers: ["Content-Type" : "application/json", "Authorization": tokenData.accessToken]
        ) { result in
            switch result {
            case .success(let responseObject):
                switch responseObject["status_code"] as? Int {
                case 200:
                    print(responseObject["message"] as Any)
                default:
                    let errorMessage = responseObject["error"] as? String
                    print("Error: \(errorMessage ?? "Unknown error case")")
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
        print("----------------------------------------\nCreatingSubscription")
    }
}
