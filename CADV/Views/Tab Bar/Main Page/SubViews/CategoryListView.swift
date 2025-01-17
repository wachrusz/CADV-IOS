//
//  CategoryListView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct CategoryList: View{
    @Binding var transactions: [CategorizedTransaction]
    @Binding var selectedCategory: String
    @Binding var selectedPlan: String
    
    var transactionType: TransactionType
    
    init(transactions: Binding<[CategorizedTransaction]>,
         selectedCategory: Binding<String>,
         selectedPlan: Binding<String>
    ) {
        self._transactions = transactions
        self._selectedCategory = selectedCategory
        self._selectedPlan = selectedPlan
        self.transactionType = TransactionType(rawValue: selectedCategory.wrappedValue) ?? .income
    }
    
    var body: some View {
        let filteredTransactions = transactions.filter { transaction in
            transaction.type == transactionType &&
            (selectedPlan == "План" ? transaction.planned == true : transaction.planned == false)
        }
        
        let groupedTransactions = Dictionary(grouping: filteredTransactions) { $0.category }
        
        if !transactions.isEmpty {
                VStack {
                    ScrollView{
                    ForEach(groupedTransactions.keys.sorted(by: { $0 < $1 }), id: \.self) { category in
                        if let categoryTransactions = groupedTransactions[category] {
                            let totalAmount = categoryTransactions.reduce(0) { $0 + $1.amount }
                            let recentTransactions = categoryTransactions.prefix(3)
                            
                            HStack {
                                Image(category.displayName)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(5)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(category.displayName)
                                        .font(.custom("Gilroy", size: 14).weight(.semibold))
                                        .foregroundColor(Color.black)
                                    
                                    ForEach(recentTransactions, id: \.id) { transaction in
                                        Text(transaction.name)
                                            .font(.custom("Gilroy", size: 12))
                                            .foregroundColor(Color.black.opacity(0.5))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text("\(colorAndSign(for: category))\(formattedTotalAmount(amount: totalAmount))")
                                        .font(.custom("Gilroy", size: 14).weight(.semibold))
                                        .foregroundColor(
                                            transactionType == .income ? Color.green :
                                                transactionType == .expense ? Color.red :
                                                Color.black
                                        )
                                    
                                    ForEach(recentTransactions, id: \.id) { transaction in
                                        Text(formattedTotalAmount(amount: transaction.amount))
                                            .font(.custom("Gilroy", size: 12))
                                            .foregroundColor(Color.black.opacity(0.5))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        }
                    }
                }
            }.onAppear(){
                let additionalData: [String: Any] = [
                    "element": "Ctaegorized_List",
                    "category": selectedCategory,
                    "plan": selectedPlan,
                ]
                
                FirebaseAnalyticsManager.shared.logUserActionEvent(
                    userId: getDeviceIdentifier(),
                    actionType: "opened",
                    screenName: "MainPageView",
                    additionalData: additionalData
                )
            }
        }else{
            CustomText(
                text: "Войдите через приложение банка, чтобы увидеть информацию о доходах, или внесите их вручную",
                font: Font.custom("Inter", size: 12).weight(.semibold),
                color: Color("sc2")
            ).onAppear(){
                let additionalData: [String: Any] = [
                    "element": "Ctaegorized_List",
                    "category": selectedCategory,
                    "plan": selectedPlan,
                ]
                
                FirebaseAnalyticsManager.shared.logUserActionEvent(
                    userId: getDeviceIdentifier(),
                    actionType: "opened",
                    screenName: "MainPageView",
                    additionalData: additionalData
                )
            }
        }
    }
    private func colorAndSign(for category: CustomCategoryType) -> String {
        switch category {
        case .income:
            return "+"
        case .expense:
            return "-"
        case .wealthFund:
            return ""
        }
    }
}
