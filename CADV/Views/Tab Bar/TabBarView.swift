//
//  TabBar.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import SwiftUI
import CoreData

struct TabBarContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var isAnalyticsLoaded = false
    @StateObject private var dataManager: DataManager
    @Binding var urlElements: URLElements?

    init(urlElements: Binding<URLElements?>) {
        self._urlElements = urlElements
        self._dataManager = StateObject(wrappedValue: DataManager(urlElements: urlElements.wrappedValue))
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }
    
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
                    .onAppear(){
                        let additionalData: [String: Any] = [
                            "element": "Main_Page"
                        ]
                        
                        FirebaseAnalyticsManager.shared.logUserActionEvent(
                            userId: getDeviceIdentifier(),
                            actionType: "opened",
                            screenName: "TabBarView",
                            additionalData: additionalData
                        )
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
                        .onAppear(){
                            let additionalData: [String: Any] = [
                                "element": "Analytics_Page"
                            ]
                            
                            FirebaseAnalyticsManager.shared.logUserActionEvent(
                                userId: getDeviceIdentifier(),
                                actionType: "opened",
                                screenName: "TabBarView",
                                additionalData: additionalData
                            )
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
                    .onAppear(){
                        let additionalData: [String: Any] = [
                            "element": "Settings_Page"
                        ]
                        
                        FirebaseAnalyticsManager.shared.logUserActionEvent(
                            userId: getDeviceIdentifier(),
                            actionType: "opened",
                            screenName: "TabBarView",
                            additionalData: additionalData
                        )
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
        .onAppear(){
            dataManager.fetchData()
        }
    }
    
    func loadAnalyticsPage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnalyticsLoaded = true
        }
    }
    
}
