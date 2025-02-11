//
//  CategorizedTransactions.swift
//  CADV
//
//  Created by Misha Vakhrushin on 29.10.2024.
//

import Foundation
import SwiftyJSON

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
    init(json: JSON) {
        self.id = UUID(uuidString: json["id"].stringValue) ?? UUID()
        self.amount = json["amount"].doubleValue
        
        let category = CustomCategoryType(from: json["category_id"].stringValue)
        self.category = category ?? .error
        
        self.currency = CurrencyType(rawValue: json["currency"].stringValue) ?? .ruble
        self.type = TransactionType(rawValue: json["type"].stringValue) ?? .income
        self.userID = json["user_id"].stringValue
        self.bankAccount = json["bank_account"].stringValue
        self.date = ISO8601DateFormatter().date(from: json["date"].stringValue) ?? Date()
        self.name = json["name"].stringValue
        self.planned = json["planned"].bool
        self.sender = json["sender"].string ?? json["sent_to"].string
        self.destinationAccount = json["destination_account"].string
    }
}
