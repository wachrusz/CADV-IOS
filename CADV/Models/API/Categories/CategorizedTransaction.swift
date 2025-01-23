//
//  CategorizedTransactions.swift
//  CADV
//
//  Created by Misha Vakhrushin on 29.10.2024.
//

import Foundation

protocol CategorizedTransactionsProtocol: Codable{
    var id: UUID { get }
    var amount: Double { get }
    var category: CustomCategoryType { get }
    var currency: CurrencyType { get }
    var type: TransactionType { get }
    var userID: String { get }
    var bankAccount: String { get }
    var date: Date { get }
    var name: String { get }
}

struct CategorizedTransaction: CategorizedTransactionsProtocol, Identifiable, Equatable, Hashable {
    var id = UUID()
    let amount: Double
    let category: CustomCategoryType
    let currency: CurrencyType
    let type: TransactionType
    let userID: String
    let bankAccount: String
    let date: Date
    let name: String
    
    var planned: Bool?
    var sender: String?
    var destinationAccount: String?
}

extension CategorizedTransaction {
    init(from json: [String: Any]) throws {
        self.id = UUID(uuidString: json["id"] as? String ?? "") ?? UUID()
        self.amount = json["amount"] as? Double ?? 0.0
        
        guard let categoryId = json["category_id"] as? String,
              let category = CustomCategoryType(from: categoryId) else {
            throw NSError(domain: "Invalid category_id", code: 1)
        }
        self.category = category
        
        self.currency = CurrencyType(rawValue: json["currency"] as? String ?? "") ?? .ruble
        self.type = TransactionType(rawValue: json["type"] as? String ?? "") ?? .income
        self.userID = json["user_id"] as? String ?? ""
        self.bankAccount = json["bank_account"] as? String ?? ""
        self.date = ISO8601DateFormatter().date(from: json["date"] as? String ?? "") ?? Date()
        self.name = json["name"] as? String ?? ""
        self.planned = json["planned"] as? Bool
        self.sender = json["sender"] as? String ?? json["sent_to"] as? String
        self.destinationAccount = json["destination_account"] as? String
    }
}
