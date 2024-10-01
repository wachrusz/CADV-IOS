//
//  File.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import Foundation

struct Incomes: Codable{
    var FactArray: [Income]
    var PlanArray: [Income]
    mutating func GetIncomes(){
        for _ in 1...100{
            let income = Income.GetIncome()
            if income.Planned{
                self.PlanArray.append(income)
            }else{
                self.FactArray.append(income)
            }
        }
    }
    func totalFactAmount() -> Double{
        var sum: Double = 0.0
        for i in self.FactArray{
            sum += i.Amount
        }
        let formattedSum = Double(String(format: "%.2f", sum)) ?? 0.0
        return formattedSum
    }
    func totalPlanAmount() -> Double{
        var sum: Double = 0.0
        for i in self.PlanArray{
            sum += i.Amount
        }
        let formattedSum = Double(String(format: "%.2f", sum)) ?? 0.0
        return formattedSum
    }
}

struct Income: Codable, Identifiable {
    var id: UUID = UUID()
    let Amount: Double
    let CategoryID: String
    let IncomeDate: String
    let ID: String
    let Planned: Bool
    let UserID: String
    let BankAccount: String
    let Sender: String
    let Currency: String

    enum CodingKeys: String, CodingKey {
        case Amount = "amount"
        case CategoryID = "category_id"
        case IncomeDate = "date"
        case ID = "id"
        case Planned = "planned"
        case UserID = "user_id"
        case BankAccount = "bank_account"
        case Sender = "sender"
        case Currency = "currency"
    }

    static func GetIncome() -> Income {
        let randomAmount = Double.random(in: 1000...10000)
        let randomCategoryID = UUID().uuidString
        let randomDate = generateRandomDate()
        let randomID = UUID().uuidString
        let randomPlanned = Bool.random()
        let randomUserID = UUID().uuidString
        let randomBankAccount = generateRandomBankAccount()
        let randomSender = "Sender \(Int.random(in: 1000000000...9999999999))"
        let randomCurrency = "RUB"

        return Income(
            Amount: randomAmount,
            CategoryID: randomCategoryID,
            IncomeDate: randomDate,
            ID: randomID,
            Planned: randomPlanned,
            UserID: randomUserID,
            BankAccount: randomBankAccount,
            Sender: randomSender,
            Currency: randomCurrency
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
