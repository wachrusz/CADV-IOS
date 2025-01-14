//
//  SettingsPage.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI

struct SettingsPageView: View {
    @State private var selectedCategory: String = "Приложение"
    @State private var pageIndex: Int = 0
    @Binding var profile: ProfileInfo
    @State private var selectedScreen: String? = nil
    @State private var isSheetPresented = false
    @StateObject var dataManager: DataManager
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    var body: some View{
        NavigationStack{
            VStack(spacing: 20){
                ProfileSection(
                    urlElements: $dataManager.urlElements,
                    profileInfo: $profile
                )
                CategorySwitchButtons(
                    selectedCategory: $selectedCategory,
                    pageIndex: $pageIndex,
                    categories: ["Приложение","Настройки"]
                )
                
                switch selectedCategory {
                case "Приложение":
                    LocalSettingsView()
                    Spacer()
                case "Настройки":
                    GlobalSettingsView()
                    Spacer()
                default:
                    LocalSettingsView()
                    Spacer()
                }
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .hideBackButton()
        }
        .onAppear(){
            self.dataManager.updateProfileData()
        }
    }
    
    private func LocalSettingsView() -> some View {
        VStack{
            ValuteSwitcherView()
            AppNavigatingButtonsList(
                selectedCategory: self.$selectedCategory,
                urlElements: self.$dataManager.urlElements
            )
        }
    }
    
    private func GlobalSettingsView() -> some View {
        AppNavigatingButtonsList(
            selectedCategory: self.$selectedCategory,
            urlElements: self.$dataManager.urlElements
        )
    }
}
