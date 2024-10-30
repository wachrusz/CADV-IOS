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
    @State private var profile: ProfileInfo = ProfileInfo(Surname: "", Name: "", UserID: "", AvatarURL: "", ExpirationDate: "")
    
    @State private var selectedScreen: String? = nil
    @State private var isSheetPresented = false
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    var body: some View{
        VStack(spacing: 20){
            VStack(spacing: 20){
                profileSection(isSheetPresented: self.$isSheetPresented, selectedScreen: self.$selectedScreen, profileInfo: $profile)
                CategorySwitchButtons()
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
        .onAppear {
            self.profile = ProfileInfo.GetProfileInfo()
        }
        .onChange(of: selectedScreen) { newValue in
            print("Selected screen changed to: \(String(describing: newValue))")
        }
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
                ProfileSettingsView(currentData: $profile)
            case "Подключённые счета":
                Text("Подключённые счета")
                    .foregroundStyle(.black)
            case "Настройка категорий":
                Text("Настройка категорий")
                    .foregroundStyle(.black)
            case "Архив операций":
                Text("Архив операций")
                    .foregroundStyle(.black)
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
                Text("Поддержка")
                    .foregroundStyle(.black)
            case "Выйти из аккаунта":
                Text("Выйти из аккаунта")
                    .foregroundStyle(.black)
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
            AppNavigatingButtonsList(selectedCategory: self.$selectedCategory, selectedScreen: self.$selectedScreen, isSheetPresented: self.$isSheetPresented)
        }
    }
    
    private func GlobalSettingsView() -> some View {
        VStack{
            AppNavigatingButtonsList(selectedCategory: self.$selectedCategory, selectedScreen: self.$selectedScreen, isSheetPresented: self.$isSheetPresented)
        }
    }
    
    private func CategorySwitchButtons() -> some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(["Приложение", "Настройки"], id: \.self) { category in
                CategorySwitchButton(text: category, isSelected: selectedCategory == category)
                    .onTapGesture {
                        selectedCategory = category
                        pageIndex = 0
                    }
            }
        }
        .padding(.horizontal)
    }
    
    
    
    private func CategorySwitchButton(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.custom("Gilroy", size: 14).weight(.semibold))
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(isSelected ? .black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(15)
    }
    

}
