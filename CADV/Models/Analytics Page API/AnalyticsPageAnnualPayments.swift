//
//  AnalyticsPageAnnualPayments.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.10.2024.
//

import Foundation

struct AnnualPayment: Codable, Identifiable{
    var id: UUID = UUID()
    let ID: String
    let name: String
    let amount: Double
    let paidAmount: Double
    let date: String
    let categoryID: Int
    let currency: String
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey{
        case name = "name"
        case amount = "amount"
        case paidAmount = "paid_amount"
        case date = "date"
        case categoryID = "category_id"
        case currency = "currency"
        case isCompleted = "is_completed"
        case ID = "id"
    }
}

func generateTestAnnualPayments() -> [AnnualPayment]{
    let randomLength = Int.random(in: 1...60)
    var array: [AnnualPayment] = []
    for _ in 1...randomLength{
        let randomNeed = Double.random(in: 5000...10000)
        let randomNeedPaid = Double.random(in: 0...5000)
        let randomGoal = UUID().uuidString
        let randomBool = Bool.random()
        
        array.append(AnnualPayment(
            id: UUID(),
            ID: UUID().uuidString,
            name: randomGoal,
            amount: randomNeed,
            paidAmount: randomNeedPaid,
            date: generateRandomDate(),
            categoryID: 1,
            currency: "RUB",
            isCompleted: randomBool
        )
        )
    }
    
    return array
}

func countCompleted(array: [AnnualPayment]) -> Int {
    return array.filter { $0.isCompleted }.count
}

func generateRandomDate() -> String {
    let randomTimeInterval = TimeInterval.random(in: -31536000...0)
    let randomDate = Date(timeIntervalSinceNow: randomTimeInterval)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: randomDate)
}
