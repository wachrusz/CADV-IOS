//
//  ValuteSwitcher.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI
import CoreData

class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: String = "rub"
    let context = PersistenceController.shared.container.viewContext
    
    init() {
        loadCurrency()
    }
    
    func loadCurrency() {
        let request: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            if let savedCurrency = results.first?.currency {
                selectedCurrency = savedCurrency
            }
        } catch {
            print("Ошибка загрузки валюты: \(error)")
        }
    }
    
    func saveCurrency(_ currency: String) {
        let request: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            let entity = results.first ?? CurrencyEntity(context: context)
            entity.currency = currency
            try context.save()
        } catch {
            print("Ошибка сохранения валюты: \(error)")
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
