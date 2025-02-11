//
//  CustomCategory.swift
//  CADV
//
//  Created by Misha Vakhrushin on 22.01.2025.
//

func image(for category: CustomCategoryType) -> String {
    switch category {
    case .error:
        return ""
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
    case error
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
        case .error: return "Error"
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
        case .error: return false
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
        case .error:
            return "Error"
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


extension CategoryEntity {
    func toCustomCategoryType() -> CustomCategoryType {
        switch self.categoryType {
        case "income":
            if let incomeConstant = IncomeConstantCategory(rawValue: self.name) {
                return .income(.constant(incomeConstant))
            } else if let incomeTemporary = IncomeTemporaryCategory(rawValue: self.name) {
                return .income(.temporary(incomeTemporary))
            }
        case "expense":
            if let expenseConstant = ExpenseConstantCategory(rawValue: self.name) {
                return .expense(.constant(expenseConstant))
            } else if let expenseTemporary = ExpenseTemporaryCategory(rawValue: self.name) {
                return .expense(.temporary(expenseTemporary))
            }
        case "wealthFund":
            if let wealthFundConstant = WealthFundConstantCategory(rawValue: self.name) {
                return .wealthFund(.constant(wealthFundConstant))
            }
        default:
            return .error
        }
        return .error
    }
}
