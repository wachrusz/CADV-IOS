//
//  Analytics Page.swift
//  CADV
//
//  Created by Misha Vakhrushin on 01.10.2024.
//

import SwiftUI

struct AnalyticsPageView: View {
    @Binding var profile: ProfileInfo
    @Binding var categorizedTransactions: [CategorizedTransaction]
    @Binding var goals: [Goal]
    @Binding var annualPayments: [AnnualPayment]
    @Binding var bankAccounts: BankAccounts
    @Binding var groupedAndSortedTransactions: [(
        date: Date, categorizedTransactions: [CategorizedTransaction]
    )]
    @Binding var currency: String
    @Binding var urlElements: URLElements?
    
    @State private var isSummaryExpanded: Bool = false
    @State private var selectedCategory: String = "Состояние"
    @State private var selectedPlan: String = "Транзакции"
    @State private var pageIndex: Int = 0
    @State private var contentHeight: CGFloat = 0
    @State private var selectedGoal: Goal?
    @State private var isEditing: Bool = false
    @State private var showAllGoalsView: Bool = false
    @State private var isLongPressing = false
    @State private var showAnnualPayments: Bool = false
    @State private var isExpanded: Bool = false
    @State private var isAddingBank = false
    @State private var isEnteringManually = false
    @State private var dragOffset = CGSize.zero
    let feedbackGeneratorMedium = UIImpactFeedbackGenerator(style: .medium)
    let feedbackGeneratorHard = UIImpactFeedbackGenerator(style: .heavy)
    
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
                        categories: ["Состояние", "Цели", "Финансовое Здоровье"]
                    )
                    switch selectedCategory{
                    case "Состояние":
                        TotalAmountView(
                            text: formattedTotalAmount(
                                amount: bankAccounts.TotalAmount
                            )
                        )
                        
                        PlanSwitcherButtons(
                            selectedPlan: $selectedPlan,
                            pageIndex: $pageIndex,
                            plans: ["Транзакции","Счета"]
                        )
                        
                        SummarySectionView(
                            selectedPlan: $selectedPlan,
                            groupedAndSortedTransactions: $groupedAndSortedTransactions,
                            bankAccounts: $bankAccounts,
                            contentHeight: $contentHeight,
                            isExpanded: $isExpanded)
                        
                        ActionButtons(
                            isFirstAction: $isAddingBank,
                            isSecondAction: $isEnteringManually,
                            firstButtonContent: AddBankAccountView(),
                            secondButtonContent: CreateBankAccountView(
                                bankAccounts: $bankAccounts,
                                currency: $currency,
                                urlElements: $urlElements
                            ),
                            firstButtonText: "Добавить банк",
                            secondButtonText: "Внести вручную",
                            firstButtonAction: {},
                            secondButtonAction: {}
                        )
                        
                    case "Цели":
                        DragGoalsView(
                            goals: $goals,
                            annualPayments: $annualPayments,
                            isLongPressing: $isLongPressing,
                            selectedGoal: $selectedGoal,
                            isEditing: $isEditing,
                            showAllGoalsView: $showAllGoalsView,
                            showAnnualPayments: $showAnnualPayments,
                            dragOffset: $dragOffset,
                            currency: $currency,
                            urlElements: $urlElements
                        )
                        
                    case "Финансовое Здоровье":
                        ErrorScreenView(
                            image: "tech",
                            text: "Этого пока нет"
                        )
                        
                    default:
                        ErrorScreenView(
                            image: "ufo",
                            text: "Упс... Что-то пошло не так"
                        )
                    }
                }
                .padding(.bottom)
                .background(Color.white)
                .hideBackButton()
                .onAppear {
                    print("Helooooooo")
                }
                .sheet(isPresented: Binding<Bool>(
                    get: { isEditing },
                    set: { newValue in
                        withAnimation {
                            isEditing = newValue
                        }
                    })) {
                        if let goal = selectedGoal {
                            EditGoalView(
                                goal: goal,
                                goals: $goals,
                                currency: $currency,
                                urlElements: $urlElements
                            )
                        } else {
                            Text("Ошибка: цель не выбрана.")
                        }
                    }
            }
        }
    }
    
    private func getNumberOfPages(itemsPerPage: Int = 20, itemsArray: [Any]) -> Int {
        return (itemsArray.count + itemsPerPage - 1) / itemsPerPage
    }
}

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
