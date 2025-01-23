//
//  ValuteSwitcher.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI
import RealmSwift

class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: String = "RUB"
    let realm = try! Realm()
    
    init() {
        loadCurrency()
    }
    
    func loadCurrency() {
        if let currencyEntity = realm.object(ofType: CurrencyEntity.self, forPrimaryKey: "currency") {
            selectedCurrency = currencyEntity.currency
        } else {
            // Если валюта не найдена, создаем новую запись с дефолтным значением
            let newCurrencyEntity = CurrencyEntity()
            newCurrencyEntity.currency = "RUB"
            do {
                try realm.write {
                    realm.add(newCurrencyEntity)
                }
            } catch {
                Logger.shared.log(.error, "Ошибка создания дефолтной валюты: \(error)")
            }
        }
    }
    
    func saveCurrency(_ currency: String) {
        if let currencyEntity = realm.object(ofType: CurrencyEntity.self, forPrimaryKey: "currency") {
            do {
                try realm.write {
                    currencyEntity.currency = currency
                }
                selectedCurrency = currency
            } catch {
                Logger.shared.log(.error, "Ошибка сохранения валюты: \(error)")
            }
        } else {
            // Если запись не найдена, создаем новую
            let newCurrencyEntity = CurrencyEntity()
            newCurrencyEntity.currency = currency
            do {
                try realm.write {
                    realm.add(newCurrencyEntity)
                }
                selectedCurrency = currency
            } catch {
                Logger.shared.log(.error, "Ошибка создания новой валюты: \(error)")
            }
        }
    }
}

struct ValuteSwitcherView: View {
    @ObservedObject var currencyManager = CurrencyManager()
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ValuteButton(
                text: "RUB",
                currency: "RUB",
                currencyManager: currencyManager
            )
            
            Divider()
                .frame(height: 20)
                .foregroundStyle(Color("fg"))
            
            ValuteButton(
                text: "USD",
                currency: "USD",
                currencyManager: currencyManager
            )
            
            Divider()
                .frame(height: 20)
                .foregroundStyle(Color("fg"))
            
            ValuteButton(
                text: "EUR",
                currency: "EUR",
                currencyManager: currencyManager
            )
        }
        .background(Color("sc1"))
        .frame(maxWidth: 300, maxHeight: 40)
        .cornerRadius(5)
    }
}

struct ValuteButton: View {
    let text: String
    let font: Font = Font.custom("Gilroy", size: 14).weight(.semibold)
    var currency: String
    @ObservedObject var currencyManager: CurrencyManager

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                currencyManager.selectedCurrency = currency
                currencyManager.saveCurrency(currency)
            }
        }) {
            CustomText(
                text: text,
                font: font,
                color: Color("fg")
            )
            .padding()
            .frame(width: 100, height: currencyManager.selectedCurrency == currency ? 40 : 35)
            .background(currencyManager.selectedCurrency == currency ? Color("bg2") : Color("sc1"))
            .cornerRadius(5)
            .scaleEffect(currencyManager.selectedCurrency == currency ? 0.9633 : 1.0)
            .shadow(color: currencyManager.selectedCurrency == currency ? Color.black.opacity(0.2) : Color.clear, radius: 5, x: 1, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
