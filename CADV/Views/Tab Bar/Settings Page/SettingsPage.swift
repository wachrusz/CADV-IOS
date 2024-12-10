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
    @Binding var tokenData: TokenData 
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    var body: some View{
        VStack(spacing: 20){
            VStack(alignment: .center, spacing: 20){
                profileSection(
                    isSheetPresented: self.$isSheetPresented,
                    selectedScreen: self.$selectedScreen,
                    profileInfo: $profile
                )
                CategorySwitchButtons(
                    selectedCategory: $selectedCategory,
                    pageIndex: $pageIndex,
                    categories: ["Приложение","Настройки"]
                )
            }
            
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
        .sheet(isPresented: $isSheetPresented) {
            if let screen = selectedScreen {
                            sheetContent(for: screen)
            } else {
                Text("Ошибка: экран не найден")
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(for screen: String?) -> some View {
        if let screen = screen {
            switch screen {
            case "Настроить профиль":
                ProfileSettingsView(
                    currentData: $profile,
                    tokenData: $tokenData
                )
            case "Подключённые счета":
                Text("Подключённые счета")
                    .foregroundStyle(.black)
            case "Настройка категорий":
                CategorySettingsView()
            case "Архив операций":
                OperationsArchiveView()
            case "Экспорт отчётности":
                Text("Экспорт отчётности")
                    .foregroundStyle(.black)
            case "Ваша подписка":
                Text("Ваша подписка")
                    .foregroundStyle(.black)
            case "Мы в соц сетях":
                Text("Мы в соц сетях")
                    .foregroundStyle(.black)
            case "Поддержка":
                SupportRequestView()
            case "Выйти из аккаунта":
                EmptyView()
            default:
                Text("Ошибка: экран не найден")
                    .foregroundStyle(.black)
            }
        } else {
            Text("Ошибка: экран не найден")
                .foregroundStyle(.black)
        }
    }
    
    private func LocalSettingsView() -> some View {
        VStack{
            ValuteSwitcherView()
            AppNavigatingButtonsList(selectedCategory: self.$selectedCategory, selectedScreen: self.$selectedScreen, isSheetPresented: self.$isSheetPresented, tokenData: self.$tokenData)
        }
    }
    
    private func GlobalSettingsView() -> some View {
        VStack{
            AppNavigatingButtonsList(selectedCategory: self.$selectedCategory, selectedScreen: self.$selectedScreen, isSheetPresented: self.$isSheetPresented, tokenData: self.$tokenData)
        }
    }
}
