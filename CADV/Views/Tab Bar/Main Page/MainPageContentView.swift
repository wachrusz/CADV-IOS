//
//  MainPageContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import SwiftUI

struct MainPageView: View {
    @Binding var profile: ProfileInfo
    @Binding var categorizedTransactions: [CategorizedTransaction]
    @Binding var urlElements: URLElements?
    @State private var selectedCategory: String = "Доходы"
    @State private var selectedPlan: String = "Факт"
    
    @State private var pageIndex: Int = 0
    @State private var isDataFetched: Bool = false
    @State private var isInAddButton = false
    @State private var isInCreateButton = false

    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                Color.white
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 30) {
                    UserProfileSection(
                        profile: $profile
                    )
                    
                    CategorySwitchButtons(
                        selectedCategory: $selectedCategory,
                        pageIndex: $pageIndex,
                        categories: ["Доходы", "Расходы", "Фонд благосостояния"]
                    )
                    
                    TotalAmountView(text: totalAmount(for: selectedCategory))
                    
                    PlanSwitcherButtons(
                        selectedPlan: $selectedPlan,
                        pageIndex: $pageIndex,
                        plans: ["Факт","План"]
                    )
                    
                    CategoryList(
                        transactions: $categorizedTransactions,
                        selectedCategory: $selectedCategory,
                        selectedPlan: $selectedPlan
                    )
                    
                    ActionButtons(
                        isFirstAction: $isInAddButton,
                        isSecondAction: $isInCreateButton,
                        firstButtonContent: ErrorScreenView(
                            image: "tech", text: "Упс... Этого нет"
                        ),
                        secondButtonContent: CreateTransactionSelectCategory(
                            selectedCategory: $selectedCategory,
                            selectedPlan: $selectedPlan
                        ),
                        firstButtonText: "Добавить банк",
                        secondButtonText: "Внести вручную",
                        firstButtonAction: {},
                        secondButtonAction: {}
                    )
                    .cornerRadius(15)
                }
            }
        }
        .padding(.bottom)
        .hideBackButton()
    }
    
    private func totalAmount(for category: String) -> String {
        let filteredTransactions = categorizedTransactions.filter { transaction in
            let isMatchingCategory: Bool
            switch transaction.category {
            case .income:
                isMatchingCategory = category == "Доходы"
            case .expense:
                isMatchingCategory = category == "Расходы"
            case .wealthFund:
                isMatchingCategory = category == "Фонд благосостояния"
            }

            return isMatchingCategory && (
                selectedPlan == "Факт" ? transaction.planned == false : transaction.planned == true
            )
        }
        
        let totalAmount = filteredTransactions.reduce(0) { $0 + $1.amount }
        
        return formattedTotalAmount(amount: totalAmount)
    }
}
