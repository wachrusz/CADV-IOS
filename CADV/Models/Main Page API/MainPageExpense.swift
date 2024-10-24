//
//  MainPageExpense.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import Foundation

struct Expenses: Codable{
    var FactArray: [Expense]
    var PlanArray: [Expense]
    mutating func GetExpenses(){
        for _ in 1...100{
            let expense = Expense.GetExpense()
            if expense.Planned{
                self.PlanArray.append(expense)
            }else{
                self.FactArray.append(expense)
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

struct Expense: Codable, Identifiable {
    let id: UUID = UUID()
    
    let Amount: Double
    let CategoryID: String
    let ExpenseDate: String
    let ID: String
    let Planned: Bool
    let UserID: String
    let BankAccount: String
    let SentTo: String
    let Currency: String

    enum CodingKeys: String, CodingKey {
        case Amount = "amount"
        case CategoryID = "category_id"
        case ExpenseDate = "date"
        case ID = "id"
        case Planned = "planned"
        case UserID = "user_id"
        case BankAccount = "bank_account"
        case SentTo = "sent_to"
        case Currency = "currency"
    }
    
    static func GetExpense() -> Expense {
        let randomAmount = Double.random(in: 1000...10000)
        let randomCategoryID = UUID().uuidString
        let randomDate = generateRandomDate()
        let randomID = UUID().uuidString
        let randomPlanned = Bool.random()
        let randomUserID = UUID().uuidString
        let randomBankAccount = generateRandomBankAccount()
        let randomSender = "Sender \(Int.random(in: 1000000000...9999999999))"
        let randomCurrency = "RUB"

        return Expense(
            Amount: randomAmount,
            CategoryID: randomCategoryID,
            ExpenseDate: randomDate,
            ID: randomID,
            Planned: randomPlanned,
            UserID: randomUserID,
            BankAccount: randomBankAccount,
            SentTo: randomSender,
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
