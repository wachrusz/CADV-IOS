//
//  TabBar.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import SwiftUI
import RealmSwift

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var isAnalyticsLoaded = false
    @StateObject private var dataManager: DataManager = DataManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                switch selectedTab {
                case 0:
                    MainPageView(
                        profile: self.$dataManager.urlEntities.profile,
                        categorizedTransactions: self.$dataManager.urlEntities.categorizedTransactions,
                        dataManager: dataManager
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        logScreenView(screenName: "Main_Page")
                    }
                case 1:
                    if isAnalyticsLoaded {
                        AnalyticsPageView(
                            profile: self.$dataManager.urlEntities.profile,
                            categorizedTransactions: self.$dataManager.urlEntities.categorizedTransactions,
                            goals: self.$dataManager.urlEntities.goals,
                            annualPayments: self.$dataManager.urlEntities.annualPayments,
                            bankAccounts: self.$dataManager.urlEntities.bankAccounts,
                            groupedAndSortedTransactions: self.$dataManager.urlEntities.groupedAndSortedTransactions,
                            dataManager: dataManager
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear {
                            logScreenView(screenName: "Analytics_Page")
                        }
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
                        profile: self.$dataManager.urlEntities.profile,
                        dataManager: dataManager
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        logScreenView(screenName: "Settings_Page")
                    }
                default:
                    MainPageView(
                        profile: self.$dataManager.urlEntities.profile,
                        categorizedTransactions: self.$dataManager.urlEntities.categorizedTransactions,
                        dataManager: dataManager
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
        .colorScheme(.light)
        .onAppear {
            dataManager.fetchData()
        }
    }
    
    private func loadAnalyticsPage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnalyticsLoaded = true
        }
    }
    
    private func logScreenView(screenName: String) {
        let additionalData: [String: Any] = [
            "element": screenName
        ]
        
        FirebaseAnalyticsManager.shared.logUserActionEvent(
            userId: getDeviceIdentifier(),
            actionType: "opened",
            screenName: "TabBarView",
            additionalData: additionalData
        )
    }
}
