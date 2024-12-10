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

func image(for category: CustomCategoryType) -> String {
    switch category {
    case .income(let income):
        switch income {
            case .constant(let category):
            switch category{
            case .salary:
                return "human"
            case .guiding:
                return "whale"
            }
            case .temporary(let category):
            switch category{
            case .savings:
                return "money_bag"
            case .gifts:
                return "gift"
            }
        }
    case .expense(let expense):
        switch expense{
            case .constant(let category):
            switch category{
            default:
                return "ufo"
            }
        case .temporary(let category):
            switch category{
            default:
                return "ufo"
            }
        }
    case .wealthFund(let category):
        switch category{
        default:
            return "ufo"
        }
    }
}

enum CustomCategoryType: CaseIterable, Codable, Hashable {
    static var allCases: [CustomCategoryType] {
        IncomeConstantCategory.allCases.map { CustomCategoryType.income(.constant($0)) } +
        IncomeTemporaryCategory.allCases.map { CustomCategoryType.income(.temporary($0)) } +
        ExpenseConstantCategory.allCases.map { CustomCategoryType.expense(.constant($0)) } +
        ExpenseTemporaryCategory.allCases.map { CustomCategoryType.expense(.temporary($0)) } +
        WealthFundConstantCategory.allCases.map { CustomCategoryType.wealthFund(.constant($0)) }
    }
    
    case income(IncomeCategory)
    case expense(ExpenseCategory)
    case wealthFund(WealthFundCategory)
}

extension CustomCategoryType: Comparable {
    static func < (lhs: CustomCategoryType, rhs: CustomCategoryType) -> Bool {
        return lhs.displayName < rhs.displayName
    }
    var displayCategory: String {
        switch self {
        case .income: return  "Доходы"
        case .expense: return "Расходы"
        case .wealthFund: return "Фонд благосостояния"
        }
    }
    
    var displayIsConstant: Bool {
        switch self {
        case .income(let category):
            switch category {
            case .constant: return true
            default: return false
            }
        case .expense(let category):
            switch category {
            case .constant: return true
            default: return false
            }
        case .wealthFund(_):
            return false
        }
    }
    
    var displayName: String {
        switch self {
        case .income(let category):
            switch category {
            case .constant(let const): return const.rawValue
            case .temporary(let temp): return temp.rawValue
            }
        case .expense(let category):
            switch category {
            case .constant(let const): return const.rawValue
            case .temporary(let temp): return temp.rawValue
            }
        case .wealthFund(let category):
            switch category {
            case .constant(let const): return const.rawValue
            }
        }
    }
}

enum IncomeCategory: Hashable, Codable {
    case constant(IncomeConstantCategory)
    case temporary(IncomeTemporaryCategory)
}

enum IncomeConstantCategory: String, CaseIterable, Codable, Hashable {
    case salary = "Зарплата"
    case guiding = "Наставничество"
}

enum IncomeTemporaryCategory: String, CaseIterable, Codable, Hashable {
    case savings = "Из сбережений"
    case gifts = "Подарки"
}

enum ExpenseCategory: Hashable, Codable {
    case constant(ExpenseConstantCategory)
    case temporary(ExpenseTemporaryCategory)
}

enum ExpenseConstantCategory: String, CaseIterable, Codable, Hashable {
    case property = "Недвижимость"
    case waterBills = "ЖКХ"
    case internetBills = "Интернет и связь"
    case insurance = "Страхка"
    case creditCard = "Кредит"
    case auto = "Транспорт"
    case education = "Образование"
}

enum ExpenseTemporaryCategory: String, CaseIterable, Codable, Hashable {
    case household = "Дом и ремонт"
    case food = "Еда"
    case vacation = "Отдых и искусство"
    case other = "Другое"
    case hardware = "Оборудование"
    case entertainment = "Развлечения"
}

enum WealthFundCategory: Hashable, Codable {
    case constant(WealthFundConstantCategory)
}

enum WealthFundConstantCategory: String, CaseIterable, Codable, Hashable {
    case valute = "Валюты"
    case investments = "Инвестиции"
    case savings = "Сбережения"
}

func generateTestTransactions(count: Int) -> [CategorizedTransaction] {
    var transactions: [CategorizedTransaction] = []
    
    for _ in 0..<count {
        let randomCategory = CustomCategoryType.allCases.randomElement()!
        let randomCurrency = CurrencyType.allCases.randomElement()!
        let randomType: TransactionType = {
            switch randomCategory {
            case .income: return .income
            case .expense: return .expense
            case .wealthFund: return .wealthFund
            }
        }()
        
        let transaction = CategorizedTransaction(
            amount: Double.random(in: 10.0...10000.0),
            category: randomCategory,
            currency: randomCurrency,
            type: randomType,
            userID: UUID().uuidString,
            bankAccount: "Bank \(Int.random(in: 1...5))",
            date: Date().addingTimeInterval(-Double.random(in: 0...100000)),
            name: "Перевод",
            planned: Bool.random(),
            sender: randomType == .income ? "Company XYZ" : nil,
            destinationAccount: randomType == .wealthFund ? "Investment Fund" : nil
        )
        
        transactions.append(transaction)
    }
    
    return transactions
}
