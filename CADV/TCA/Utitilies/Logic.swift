//
//  Logic.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import Foundation

func getNumberOfPages(itemsPerPage: Int = 20, itemsArray: [Any]) -> Int {
    return (itemsArray.count + itemsPerPage - 1) / itemsPerPage
}

func getTransactionsForPage(pageIndex: Int, groupedTransactions: [(date: Date, transactions: [Transaction])]) -> [(date: Date, transactions: [Transaction])] {
    let start = pageIndex * 5
    let end = min(start + 5, groupedTransactions.count)
    return Array(groupedTransactions[start..<end])
}

func getGroupedTransactions(_ transactions: [Transaction]) -> [(date: Date, transactions: [Transaction])] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let grouped = Dictionary(grouping: transactions) { transaction -> Date in
        if let date = dateFormatter.date(from: transaction.date) {
            return Calendar.current.startOfDay(for: date)
        } else {
            return Date()
        }
    }
    
    return grouped.map { (key: Date, value: [Transaction]) in
        (date: key, transactions: value)
    }
}

func monthsBetween(startDate: Date, endDate: Date) -> CGFloat? {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month], from: startDate, to: endDate)
    return CGFloat(components.month ?? 1)
}

func monthsPassedInts(from startDateString: String, to endDateString: String) -> (CGFloat, CGFloat) {
    guard let startDate = stringToDate(startDateString), let endDate = stringToDate(endDateString) else {
        return (0, 1)
    }
    
    guard let monthsTotal = monthsBetween(startDate: startDate, endDate: endDate) else {
        return (0, 1)
    }
    
    let monthsPassed = monthsBetween(startDate: startDate, endDate: Date()) ?? 1
    
    return (monthsPassed, monthsTotal)
}

