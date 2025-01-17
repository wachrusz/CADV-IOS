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
            case .property:
                return "home"
            case .waterBills:
                return "office"
            case .internetBills:
                return "phone"
            case .insurance:
                return "deal"
            case .creditCard:
                return "calendar"
            case .auto:
                return "auto"
            case .education:
                return "education"
            default:
                return "ufo"
            }
        case .temporary(let category):
            switch category{
            case .household:
                return "tech"
            case .food:
                return "food"
            case .vacation:
                return "palette"
            case .other:
                return "ufo"
            case .hardware:
                return "laptop"
            case .entertainment:
                return "pinata"
            default:
                return "ufo"
            }
        }
    case .wealthFund(let category):
        switch category{
        case .constant(let category):
            switch category{
            case .investments:
                return "briefcase"
            case .savings:
                return "money_bag"
            case .valute:
                return "cash"
            default:
                return "ufo"
            }
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
        case .wealthFund: return "Сбережения"
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

extension CustomCategoryType {
    init?(from categoryId: String) {
        if let incomeConstant = IncomeConstantCategory(rawValue: categoryId) {
            self = .income(.constant(incomeConstant))
            return
        }
        if let incomeTemporary = IncomeTemporaryCategory(rawValue: categoryId) {
            self = .income(.temporary(incomeTemporary))
            return
        }
        
        if let expenseConstant = ExpenseConstantCategory(rawValue: categoryId) {
            self = .expense(.constant(expenseConstant))
            return
        }
        if let expenseTemporary = ExpenseTemporaryCategory(rawValue: categoryId) {
            self = .expense(.temporary(expenseTemporary))
            return
        }
        
        if let wealthFundConstant = WealthFundConstantCategory(rawValue: categoryId) {
            self = .wealthFund(.constant(wealthFundConstant))
            return
        }
        
        return nil
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
