//
//  AnalyticsPageBankAccounts.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.10.2024.
//

import Foundation

struct BankAccounts: Sequence, RandomAccessCollection {
    var Array: [BankAccount]
    var TotalAmount: Double {self.Array.reduce(0) { $0 + $1.totalAmount }}
    var Group: BankAccountsGroup?
    var Currency: CurrencyType = .ruble
    
    func makeIterator() -> Array<BankAccount>.Iterator {
        return Array.makeIterator()
    }
    
    var startIndex: Int { return Array.startIndex }
    var endIndex: Int { return Array.endIndex }
    
    func index(after i: Int) -> Int {
        return Array.index(after: i)
    }
    
    subscript(position: Int) -> BankAccount {
        return Array[position]
    }
    
    mutating func getBankAccounts() {
        self.Array = BankAccount.getBankAccounts()
    }
}

struct BankAccount: Codable, Hashable, Identifiable {
    static func == (lhs: BankAccount, rhs: BankAccount) -> Bool {
        return lhs.totalAmount > rhs.totalAmount
    }
    
    var id = UUID()
    let totalAmount: Double
    let name: String
    let subAccounts: [SubAccount]
    
    enum CodingKeys: String, CodingKey {
        case totalAmount = "amount"
        case subAccounts = "sub_accounts"
        case name = "name"
    }
    
    static func getBankAccounts() -> [BankAccount] {
        let names = ["Raiffeisen", "T-Bank", "Sber", "Gazprombank", "VTB"]
        var accounts: [BankAccount] = []
        
        let numberOfAccounts = Int.random(in: 1...5)
        let shuffledNames = names.shuffled().prefix(numberOfAccounts)
        
        for name in shuffledNames {
            let subAccounts = SubAccount.getSubAccounts()
            let totalAmount = subAccounts.reduce(0) { $0 + $1.totalAmount }
            let account = BankAccount(totalAmount: totalAmount, name: name, subAccounts: subAccounts)
            accounts.append(account)
        }
        
        return accounts
    }
}

struct SubAccount: Codable, Hashable, Identifiable {
    let id = UUID()
    let number: String
    let name: String
    let totalAmount: Double
    let currency: CurrencyType
    
    enum CodingKeys: String, CodingKey {
        case number = "number"
        case name = "name"
        case totalAmount = "total_amount"
        case currency = "currency"
    }
    
    // Генерация случайного количества субсчетов (от 1 до 5)
    static func getSubAccounts() -> [SubAccount] {
        let names = ["IIS", "Card", "Broker Account", "Savings"]
        var subAccounts: [SubAccount] = []
        
        // Генерация случайного количества субсчетов
        let numberOfSubAccounts = Int.random(in: 1...5)
        let shuffledNames = names.shuffled().prefix(numberOfSubAccounts)
        
        for name in shuffledNames {
            let number = UUID().uuidString.prefix(10)
            let totalAmount = Double.random(in: 1000...50000)
            let currency = CurrencyType.allCases.randomElement() ?? .dollar
            let subAccount = SubAccount(number: String(number), name: name, totalAmount: totalAmount, currency: currency)
            subAccounts.append(subAccount)
        }
        
        return subAccounts
    }
}
