//
//  Formatters.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import Foundation

extension Date {
    func monthDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}

func formattedTotalAmount(amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = "."
    
    if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
        return formattedAmount
    }
    return "\(amount)"
}

func currencyCodeToSymbol(code: String) -> String{
    switch code{
    case "RUB":
        return "₽"
    case "EUR":
        return "€"
    case "USD":
        return "$"
    default:
        return "₽"
    }
}

func currencyCodeAndTypeToSymbol(type: TransactionType, code: String) -> String {
    switch code{
    case "RUB":
        return "\(type.rawValue == "Доход" ? "+" : "-")₽"
    case "EUR":
        return "\(type.rawValue == "Доход" ? "+" : "-")€"
    case "USD":
        return "\(type.rawValue == "Доход" ? "+" : "-")$"
    default:
        return "\(type.rawValue == "Доход" ? "+" : "-")₽"
    }
}

func stringToDate(_ dateString: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    
    if dateString.contains(".") {
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    } else {
        dateFormatter.formatOptions = [.withInternetDateTime]
    }

    if let date = dateFormatter.date(from: dateString) {
        return date
    } else {
        Logger.shared.log(.error, "Ошибка: Не удалось преобразовать строку в дату.")
        return nil
    }
}
