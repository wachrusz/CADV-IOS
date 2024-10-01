//
//  MainPageInvestments.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import Foundation

struct WealthFunds: Codable{
    var PlanArray: [WealthFund]
    var FactArray: [WealthFund]
    mutating func GetWealthFunds(){
        for _ in 1...100{
            let wealthFund = WealthFund.GetWealthFund()
            if wealthFund.Planned{
                self.PlanArray.append(wealthFund)
            }else{
                self.FactArray.append(wealthFund)
            }
        }
    }
    func totalPlanAmount() -> Double{
        var sum: Double = 0.0
        for i in self.PlanArray{
            sum += i.Amount
        }
        let formattedSum = Double(String(format: "%.2f", sum)) ?? 0.0
        return formattedSum
    }
    func totalFactAmount() -> Double{
        var sum: Double = 0.0
        for i in self.FactArray{
            sum += i.Amount
        }
        let formattedSum = Double(String(format: "%.2f", sum)) ?? 0.0
        return formattedSum
    }
}

struct WealthFund: Codable, Identifiable {
    let id: UUID = UUID()
    
    let Amount: Double
    let WealthFundDate: String
    let ID: String
    let Planned: Bool
    let UserID: String
    let BankAccount: String
    let Currency: String
    let CategoryID: String

    enum CodingKeys: String, CodingKey {
        case Amount = "amount"
        case WealthFundDate = "date"
        case ID = "id"
        case Planned = "planned"
        case UserID = "user_id"
        case BankAccount = "bank_account"
        case Currency = "currency"
        case CategoryID = "category_id"
    }

    static func GetWealthFund() -> WealthFund {
        let randomAmount = Double.random(in: 1000...10000)
        let randomCategoryID = UUID().uuidString
        let randomDate = generateRandomDate()
        let randomID = UUID().uuidString
        let randomPlanned = Bool.random()
        let randomUserID = UUID().uuidString
        let randomBankAccount = generateRandomBankAccount()
        let randomSender = "Sender \(Int.random(in: 1000000000...9999999999))"
        let randomCurrency = "RUB"

        return WealthFund(
            Amount: randomAmount,
            WealthFundDate: randomCategoryID,
            ID: randomDate,
            Planned: randomPlanned,
            UserID: randomID,
            BankAccount: randomUserID,
            Currency: randomBankAccount,
            CategoryID: randomCurrency
        )
    }

    // Генерация случайной даты
    private static func generateRandomDate() -> String {
        let randomTimeInterval = TimeInterval.random(in: -31536000...0)
        let randomDate = Date(timeIntervalSinceNow: randomTimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: randomDate)
    }

    // Генерация случайного номера банковского счета
    private static func generateRandomBankAccount() -> String {
        let randomDigits = (0..<20).map { _ in String(Int.random(in: 0...9)) }.joined()
        return randomDigits
    }
}
