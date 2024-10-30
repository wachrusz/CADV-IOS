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
    @State private var selectedCategory: String = "Доходы"
    @State private var selectedPlan: String = "Факт"
    
    @State private var pageIndex: Int = 0
    @State private var isDataFetched: Bool = false
    @State private var isInAddButton = false
    @State private var isInCreateButton = false

    var body: some View {
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
                    fontName: "Inter",
                    fontSize: 14,
                    categories: ["Доходы", "Расходы", "Фонд благосостояния"]
                )
                
                TotalAmountView(text: totalAmount(for: selectedCategory))
                
                PlanSwitcherButtons(
                    selectedPlan: $selectedPlan,
                    pageIndex: $pageIndex,
                    fontName: "Inter",
                    fontSize: 14,
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
                    secondButtonContent: ErrorScreenView(
                        image: "tech", text: "Упс.. Этого нет"
                    ),
                    firstButtonText: "Добавить банк",
                    secondButtonText: "Внести вручную",
                    fontName: "Inter",
                    fontSize: 14,
                    firstButtonAction: {},
                    secondButtonAction: {}
                )
            }
        }
        .padding(.bottom)
        .background(Color.white)
        .hideBackButton()
        .onAppear {
            print("Hellooooooooooo")
        }
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
