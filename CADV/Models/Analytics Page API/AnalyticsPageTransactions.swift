//
//  AnalyticsPageTransactions.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.10.2024.
//

import Foundation

struct Transactions: Sequence{
    var Array: [Transaction]
    
    func makeIterator() -> Array<Transaction>.Iterator {
            return Array.makeIterator()
    }
    
    mutating func getTransactions(){
        self.Array = Transaction.getTransactions()
    }
}

enum BankAccountsGroup: String, Codable, Hashable, CaseIterable{
    case cash = "Наличные"
    case bank = "Банк"
}

enum TransactionType: String, Codable, Hashable {
    case income = "Доход"
    case expense = "Расход"
}

enum CategoryType: String, Codable, Hashable {
    case salary = "Зарплата"
    case freelance = "Фриланс"
    case investment = "Инвестиции"
    case rentalIncome = "Арендный доход"
    case gift = "Подарок"
    case food = "Еда"
    case transportation = "Транспорт"
    case entertainment = "Развлечения"
    case utilities = "Коммунальные услуги"
    case housing = "Жилище"
    case healthcare = "Здоровье"
    case education = "Образование"
    case clothing = "Одежда"
    case personalCare = "Личная гигиена"
    case other = "Прочее"
}

enum CurrencyType: String, Codable, Hashable, CaseIterable {
    case ruble = "RUB"
    case euro = "EUR"
    case dollar = "USD"
}

struct Transaction: Codable, Identifiable, Hashable{
    var id = UUID()
    let amount: Double
    let name: String
    let date: String
    let category: CategoryType
    let type: TransactionType
    let currency: CurrencyType
    
    enum CodingKeys: String, CodingKey{
        case amount = "amount"
        case date = "date"
        case category = "category"
        case type = "type"
        case currency = "currency"
        case name = "name"
    }
    
    var dateObject: Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: date)
    }
    
    static func getTransactions() -> [Transaction] {
        let names = ["Salary", "Freelance", "Food", "Transport", "Entertainment", "Utilities", "Housing", "Healthcare", "Education", "Clothing", "Personal Care", "Other"]
        let categories: [CategoryType] = [.salary, .freelance, .food, .transportation, .entertainment, .utilities, .housing, .healthcare, .education, .clothing, .personalCare, .other]
        let types: [TransactionType] = [.income, .expense]
        let currencies: [CurrencyType] = [.ruble, .euro, .dollar]
        
        var transactions: [Transaction] = []
        
        for _ in 0..<20 {
            let randomName = names.randomElement()!
            let randomCategory = categories.randomElement()!
            let randomType = types.randomElement()!
            let randomCurrency = currencies.randomElement()!
            let randomAmount = Double.random(in: 10...1000)
            let randomDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...30), to: Date())!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let randomDateString = dateFormatter.string(from: randomDate)
            
            let transaction = Transaction(amount: randomAmount, name: randomName, date: randomDateString, category: randomCategory, type: randomType, currency: randomCurrency)
            transactions.append(transaction)
        }
        
        return transactions
    }
    
}
