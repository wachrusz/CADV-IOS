//
//  AppNavigatingButtonsList.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI

struct AppNavigatingButtonsList: View {
    @Binding var selectedCategory: String
    @Binding var selectedScreen: String?
    @Binding var isSheetPresented: Bool
    var body: some View{
        VStack {
            ForEach(getButtonsData(), id: \.0) { button in
                AppNavigatingButton(image: button.2, text: button.0, description: button.1)
                    .onTapGesture {
                        handleButtonTap(button.0)
                    }
            }
        }
    }
    func handleButtonTap(_ screen: String) {
        selectedScreen = screen
        isSheetPresented = true
        print(selectedScreen, isSheetPresented)
    }
    func AppNavigatingButton(image: String, text: String, description: String) -> some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: 45,height: 45, alignment: .leading)
                .padding()

            VStack(alignment: .leading) {
                CustomText(
                    text: text,
                    font: Font.custom("Gilroy", size: 16).weight(.semibold),
                    color: Color("fg")
                )
                
                CustomText(
                    text: description,
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("sc2")
                )
            }
            Spacer()
        }
        .frame(maxWidth: 300, maxHeight: 75)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    func getButtonsData() -> [(String, String, String)] {
        var buttonsData: [(String, String, String)] = []
        switch selectedCategory{
        case "Приложение":
            buttonsData = [
                ("Подключённые счета", "Данные о подключенных банках", "Bank"),
                ("Настройка категорий", "Управляйте категориями легко", "CardDivider"),
                ("Архив операций", "Исходные операции объединения", "WasteBasket"),
                ("Экспорт отчётности","Все ваши финансы в формате Excel", "Papers")
            ]
            return buttonsData
        case "Настройки":
            buttonsData = [
                ("Ваша подписка", "Всё про цену и возможности сервиса", "subscription"),
                ("Мы в соц сетях", "Наши полезные ресурсы", "social"),
                ("Поддержка", "Задайте вопрос или предложите улучшение приложения", "supportRequest"),
                ("Выйти из аккаунта","", "logout")
            ]
            return buttonsData
        default:
            return buttonsData
        }
    }
}




