//
//  AppNavigatingButtonsList.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI

struct AppNavigatingButtonsList: View {
    @Binding var selectedCategory: String
    @Binding var urlElements: URLElements?
    
    var body: some View {
        VStack {
            ForEach(getButtonsData(), id: \.0) { button in
                if button.0 == "Выйти из аккаунта" {
                    AppNavigatingButton(image: button.2, text: button.0, description: button.1)
                        .onTapGesture {
                            handleLogout()
                        }
                } else {
                    NavigationLink(destination: getDestinationView(for: button.0)) {
                        AppNavigatingButton(image: button.2, text: button.0, description: button.1)
                    }
                }
            }
        }
    }
    
    func handleLogout() {
        Task {
            await logout()
        }
    }
    
    func getButtonsData() -> [(String, String, String)] {
        var buttonsData: [(String, String, String)] = []
        switch selectedCategory {
        case "Приложение":
            buttonsData = [
                ("Подключённые счета", "Данные о подключенных банках", "Bank"),
                ("Настройка категорий", "Управляйте категориями легко", "CardDivider"),
                ("Архив операций", "Исходные операции объединения", "WasteBasket"),
                ("Экспорт отчётности", "Все ваши финансы в формате Excel", "Papers")
            ]
            return buttonsData
        case "Настройки":
            buttonsData = [
                ("Ваша подписка", "Всё про цену и возможности сервиса", "subscription"),
                ("Мы в соц сетях", "Наши полезные ресурсы", "social"),
                ("Поддержка", "Задайте вопрос или предложите улучшение приложения", "supportRequest"),
                ("Выйти из аккаунта", "", "logout")
            ]
            return buttonsData
        default:
            return buttonsData
        }
    }
    
    @ViewBuilder
    func getDestinationView(for screen: String) -> some View {
        switch screen {
        case "Подключённые счета":
            Text("Подключённые счета")
                .foregroundStyle(.black)
        case "Настройка категорий":
            CategorySettingsView(urlElements: $urlElements)
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
        default:
            Text("Ошибка: экран не найден")
                .foregroundStyle(.black)
        }
    }
    
    private func logout() async {
        do {
            let response = try await urlElements?.fetchData(
                endpoint: "v1/auth/logout",
                method: "POST",
                needsAuthorization: true
            )
            switch response?["status_code"] as? Int {
            case 200:
                urlElements?.deleteAllEntities()
            default:
                Logger.shared.log(.error, "Failed to fetch goals.")
            }
        } catch {
            Logger.shared.log(.error, "Error logging out: \(error)")
        }
    }
}

struct AppNavigatingButton: View {
    let image: String
    let text: String
    let description: String
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: 45, height: 45, alignment: .leading)
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
        .frame(maxWidth: 300, maxHeight: 65)
        .background(Color("bg1"))
        .cornerRadius(15)
    }
}
