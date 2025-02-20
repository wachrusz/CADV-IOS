//
//  AnalyticsPageBankAccounts.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.10.2024.
//

import Foundation

struct BankAccounts: Sequence, RandomAccessCollection, Equatable, Identifiable {
    let id: UUID = UUID()
    var Array: [BankAccount] = []
    var TotalAmount: Double {self.Array.reduce(0) { $0 + $1.totalAmount }}
    var Group: BankAccountsGroup = .bank
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
}

struct BankAccount: Codable, Hashable, Identifiable {
    static func == (lhs: BankAccount, rhs: BankAccount) -> Bool {
        return lhs.totalAmount > rhs.totalAmount
    }
    
    var id = UUID()
    let bankID: Int
    var totalAmount: Double
    let name: String
    var subAccounts: [SubAccount]
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
        case totalAmount = "state"
        case currency = "currency"
    }
}
