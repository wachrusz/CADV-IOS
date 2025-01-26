//
//  SummarySection.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct SummarySectionView: View {
    @Binding var selectedPlan: String
    @Binding var groupedAndSortedTransactions: [(
        date: Date, categorizedTransactions: [CategorizedTransaction]
    )]
    @Binding var bankAccounts: [Int : BankAccounts]
    @Binding var contentHeight: CGFloat
    @Binding var isExpanded: Bool
    @State private var loadedTransactionsPerDate: [Date: Int] = [:]
    @State private var bankAccountsIsEmpty: Bool = true
    
    
    var body: some View {
        ZStack{
            switch selectedPlan{
            case "Транзакции":
                if bankAccounts.isEmpty || groupedAndSortedTransactions.isEmpty {
                    VStack {
                        CustomText(
                            text: "Подключите приложение банка, чтобы данные о ваших финансах учитывались автоматически или добавьте информацию о наличном счете, чтобы учитывать операции с наличными",
                            font: Font.custom("Inter", size: 12).weight(.semibold),
                            color: Color("sc2")
                        )
                        .padding()
                        .onAppear {
                            Logger.shared.log(.warning, "Starting checking bank accounts")
                            for value in bankAccounts.values {
                                Logger.shared.log(.warning, value)
                                if !value.Array.isEmpty {
                                    Logger.shared.log(.warning, value)
                                    self.bankAccountsIsEmpty = false
                                }
                            }
                        }
                    }
                }else{
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(groupedAndSortedTransactions, id: \.date) { group in
                                Section(header: Text(group.date, style: .date).foregroundColor(Color.black)) {
                                    
                                    let transactionsToDisplay = getTransactionsForDate(date: group.date, transactions: group.categorizedTransactions)
                                    
                                    ForEach(transactionsToDisplay, id: \.id) { transaction in
                                        TransactionElement(transaction: transaction)
                                            .onAppear {
                                                handleLoadMoreTransactions(date: group.date, currentTransaction: transaction, transactions: group.categorizedTransactions)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .animation(.easeInOut, value: loadedTransactionsPerDate)
                    .frame(maxHeight: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .onAppear {
                        Logger.shared.log(.warning, "Starting checking bank accounts")
                        for value in bankAccounts.values {
                            Logger.shared.log(.warning, value)
                            if !value.Array.isEmpty {
                                Logger.shared.log(.warning, value)
                                self.bankAccountsIsEmpty = false
                            }
                        }
                    }
                }
            case "Счета":
                if bankAccountsIsEmpty {
                    VStack {
                        CustomText(
                            text: "Подключите приложение банка, чтобы данные о ваших финансах учитывались автоматически или добавьте информацию о наличном счете, чтобы учитывать операции с наличными",
                            font: Font.custom("Inter", size: 12).weight(.semibold),
                            color: Color("sc2")
                        )
                        .padding()
                    }
                }else{
                    VStack {
                        if (contentHeight > 150 && !isExpanded) || (contentHeight <= 150) {
                            VStack(spacing: 10) {
                                ForEach(Array(bankAccounts.values)) { bankAccount in
                                    BankAccountList(bankAccounts: bankAccount)
                                }
                            }
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            contentHeight = geometry.size.height
                                        }
                                }
                            )
                            .frame(maxHeight: min(contentHeight, 150), alignment: .top)
                            .background(Color.white)
                            .cornerRadius(10)
                            .opacity(isExpanded ? 0 : 1)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0), Color.white]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .opacity(contentHeight < 150 ? 0 : 1)
                            )
                            .animation(.easeInOut(duration: 0.1), value: contentHeight)
                        } else {
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(Array(bankAccounts.values)) { bankAccount in
                                        BankAccountList(bankAccounts: bankAccount)
                                    }
                                }
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                contentHeight = geometry.size.height
                                            }
                                    }
                                )
                                .frame(maxHeight: isExpanded ? .infinity : min(contentHeight, 150), alignment: .top)
                                .background(Color.white)
                                .cornerRadius(10)
                                .opacity(isExpanded ? 1 : 0)
                                .animation(.easeInOut(duration: 0.1), value: contentHeight)
                            }
                        }
                        
                        if contentHeight > 150 {
                            Button(action: {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            }) {
                                Text(isExpanded ? "Свернуть" : "Развернуть")
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    .padding()
                }
            default:
                EmptyView()
            }
        }
    }
    
    private func getTransactionsForDate(date: Date, transactions: [CategorizedTransaction]) -> [CategorizedTransaction] {
        let loadedCount = loadedTransactionsPerDate[date] ?? 6
        return Array(transactions.prefix(loadedCount))
    }

    private func handleLoadMoreTransactions(date: Date, currentTransaction: CategorizedTransaction, transactions: [CategorizedTransaction]) {
        let loadedCount = loadedTransactionsPerDate[date] ?? 6
        
        if let currentIndex = transactions.firstIndex(of: currentTransaction), currentIndex == loadedCount - 1 {
            loadMoreTransactions(for: date, totalCount: transactions.count)
        }
    }

    private func loadMoreTransactions(for date: Date, totalCount: Int) {
        if (loadedTransactionsPerDate[date] ?? 0) < totalCount {
            loadedTransactionsPerDate[date, default: 6] += 6
        }
    }
}
