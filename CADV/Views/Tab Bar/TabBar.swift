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

extension TokenData {
    init(from entity: AccessEntity) {
        self.accessToken = entity.accessToken ?? ""
        self.refreshToken = entity.refreshToken ?? ""
        self.accessTokenExpiresAt = entity.accessTokenExpiresAt ?? Date()
        self.refreshTokenExpiresAt = Date().addingTimeInterval(TimeInterval(entity.refreshTokenLifeTime))
    }
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
        Task{
            await   fetchProfileData()
            await   fetchTracker()
            await   fetchMain()
        }
        
        self.groupedAndSortedTransactions = getGroupedTransactionsAndSortByDate(categorizedTransactions)
        self.groupedAndSortedTransactions = filterTransactions(categorizedTransactions, gns: groupedAndSortedTransactions)
    }
    
    func fetchCurrency(){
        let fetchRequest: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do{
            let currency = try viewContext.fetch(fetchRequest)
            if !currency.isEmpty{
                self.currency = currency[0].currency ?? ""
            }
        }catch{
            print(error)
        }
    }
    
    func fetchMain() async{
        do{
            let response = try await abstractFetchData(
                endpoint: "v1/profile/analytics?limit=20&offset=0",
                method: "GET",
                headers: ["accept" : "application/json", "Authorization" : tokenData.accessToken, "X-Currency": self.currency]
            )
            switch response["status_code"] as? Int {
            case 200:
                print(response)
            default:
                print("Failed to fetch goals.")
            }
        }catch{
            
        }
    }
    
    func fetchTracker() async{
        do {
            let response = try await abstractFetchData(
                endpoint: "v1/profile/tracker?limit=20&offset=0",
                method: "GET",
                headers: ["accept" : "application/json", "Authorization" : tokenData.accessToken, "X-Currency": self.currency]
            )
            switch response["status_code"] as? Int {
            case 200:
                print(response)
                
                guard
                    let tracker = response["tracker"] as? [String: Any],
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
        }catch{
            
        }

    }
    
    func fetchProfileData(attemptsLeft: Int = 3) async{
        do{
            let response = try await abstractFetchData(
                endpoint: "v1/profile",
                method: "GET",
                headers: ["accept" : "application/json", "Authorization": tokenData.accessToken]
            )
            switch response["status_code"] as? Int {
            case 200:
                print(response)
                guard let profileData = try? JSONSerialization.data(withJSONObject: response["profile"] ?? [:], options: []) else {
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
                refreshTokenIfNeeded(tokenData, viewCtx: viewContext){ success in
                    if success {
                        print("Token refreshed successfully, rechecking...")
                        Task{
                            await self.fetchProfileData(attemptsLeft: attemptsLeft - 1)
                        }
                    } else {
                        print("Failed to refresh token, attempts left: \(attemptsLeft - 1)")
                        Task{
                            await self.fetchProfileData(attemptsLeft: attemptsLeft - 1)
                        }
                    }
                }
            default:
                let errorMessage = response["error"] as? String
                print("Error: \(errorMessage ?? "Unknown error case")")
            }
        }catch let error{
            print(error)
        }
    }

    func createSubscription() async{
        print("----------------------------------------\nCreatingSubscription")
        let parameters = [
            "end_date": "20-01-2025",
            "is_active": true,
            "start_date": "\(Date().formatted(.iso8601))",
            "user_id": ""
        ] as [String : Any]
        do {
        let response = try await abstractFetchData(
            endpoint: "v1/settings/subscription",
            method: "POST",
            parameters: parameters,
            headers: ["Content-Type" : "application/json", "Authorization": tokenData.accessToken]
        )
            switch response["status_code"] as? Int {
            case 200:
                print(response["message"] as Any)
            default:
                let errorMessage = response["error"] as? String
                print("Error: \(errorMessage ?? "Unknown error case")")
            }
        }catch{
            
        }
    }
    
    public mutating func setTokenData(_ tokenData: TokenData){
        self.tokenData = tokenData
    }
}


func refreshTokenIfNeeded(
    _ tokenData: TokenData,
    viewCtx: NSManagedObjectContext,
    completion: @escaping (Bool) -> Void
) {
    if tokenData.accessTokenExpiresAt < Date(timeIntervalSinceNow: 10) {
        Task {
            let success = await refreshToken(tokenData, viewCtx: viewCtx)
            completion(success)
        }
    } else {
        completion(true)
    }
}

func refreshToken(_ tokenData: TokenData, viewCtx: NSManagedObjectContext) async -> Bool {
    print("Started refresh")
    do {
        let response = try await abstractFetchData(
            endpoint: "v1/auth/refresh",
            method: "POST",
            parameters: ["refresh_token": tokenData.refreshToken],
            headers: ["Content-Type": "application/json", "Authorization": tokenData.accessToken]
        )
        switch response["status_code"] as? Int {
        case 200:
            if let newToken = response["access_token"] as? String,
               let newRefreshToken = response["refresh_token"] as? String {
                saveNewTokens(token: newToken, refreshToken: newRefreshToken, viewCtx: viewCtx)
                print("Token refreshed successfully")
                return true
            }
        default:
            let errorMessage = response["error"] as? String
            print("Error refreshing token: \(errorMessage ?? "Unknown error case")")
        }
    } catch {
        print("Failed to refresh token: \(error.localizedDescription)")
    }
    return false
}

func saveNewTokens(
    token: String,
    refreshToken: String,
    viewCtx: NSManagedObjectContext
){
    print("----------------------------------------\nSavingNewTokens")
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
        print("Failed to fetch or save refreshed token: \(error.localizedDescription)")
    }
    print("----------------------------------------\nSavingNewTokens")
}
