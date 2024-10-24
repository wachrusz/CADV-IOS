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
        HStack(alignment: .center, spacing: 20) {
            ForEach(["RUB", "USD", "EUR"], id: \.self) { currency in
                Button(action: {
                    currencyManager.selectedCurrency = currency
                    currencyManager.saveCurrency(currency)
                }) {
                    Text(currency.uppercased())
                        .foregroundColor(currencyManager.selectedCurrency == currency ? .white : .blue)
                        .padding()
                        .background(currencyManager.selectedCurrency == currency ? Color.blue : Color.clear)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

