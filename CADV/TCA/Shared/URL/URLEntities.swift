//
//  URLEntities.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.12.2024.
//

import Foundation

class URLEntities {
    
    static let shared = URLEntities()
    
    var categorizedTransactions: [CategorizedTransaction]
    var profile: ProfileInfo
    var goals: [Goal]
    var finHealth: FinHealth
    var annualPayments: [AnnualPayment]
    var bankAccounts: [Int : BankAccounts]
    var groupedAndSortedTransactions: [(date: Date, categorizedTransactions: [CategorizedTransaction])] = []
    
    init() {
        self.categorizedTransactions = []
        self.profile = test_fetchProfileInfo()
        self.goals = []
        self.finHealth = FinHealth()
        self.annualPayments = []
        self.bankAccounts =  [
            0: BankAccounts()
        ]
    }
    
    func getGroupedTransactions()
    {
        let groupedTransactions = Dictionary(
            grouping: categorizedTransactions,
            by: { Calendar.current.startOfDay(for: $0.date) }
        )
        
        let sortedTransactions = groupedTransactions.keys.sorted(by: >).map { date in
            let transactions = groupedTransactions[date]!
            let count = transactions.count
            Logger.shared.log(.info, "date: \(date), ctgTrz: \(count)")
            return (date: date, categorizedTransactions: transactions)
        }
        
        self.groupedAndSortedTransactions = filterTransactions(self.categorizedTransactions, gns: sortedTransactions)
    }
    
    func filterTransactions(
        _ categorizedTransactions: [CategorizedTransaction],
        gns: [(date: Date, categorizedTransactions: [CategorizedTransaction])]
    ) -> [(date: Date, categorizedTransactions: [CategorizedTransaction])] {
        let filteredTransactions = gns
            .map { (date: $0.date, categorizedTransactions: $0.categorizedTransactions.filter { transaction in
                switch transaction.category {
                case .wealthFund:
                    return false
                default:
                    return true
                }
            })}
            .filter { !$0.categorizedTransactions.isEmpty }
        
        return filteredTransactions
    }
}
