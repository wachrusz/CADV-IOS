//
//  CreateTransaction.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.11.2024.
//

import SwiftUI
import RealmSwift

struct CreateTransactionSelectCategory: View {
    @Binding var selectedCategory: String
    @Binding var selectedPlan: String
    
    @State private var customCategoriesFilteredConstant: [CustomCategoryType] = []
    @State private var customCategoriesFilteredTemporary: [CustomCategoryType] = []
    @ThreadSafe private var savedCategories: Results<CategoryEntity>?
    
    @State private var navigationTitle: String = ""
    
    private func Steps() -> some View {
        HStack(alignment: .center, spacing: 20) {
            StepView(number: "1", currentStep: 1, stepIndex: 1)
            StepView(number: "2", currentStep: 1, stepIndex: 2)
        }
        .padding(.top)
    }
    
    private func StepName() -> some View{
        CustomText(
            text: "Выбор категории",
            font: Font.custom("Gilroy", size: 12).weight(.semibold),
            color: Color("fg")
        )
        .padding(.vertical)
    }
    
    private func ForEachConstantCustom() -> some View{
        ForEach(customCategoriesFilteredConstant, id: \.self) { category in
            CustomTransactionElementView(
                selectedCategory: $selectedCategory,
                selectedPlan: $selectedPlan,
                category: category
            )
        }
    }
    
    private func ForEachConstantSaved() -> some View{
        Group{
            if let savedCategories = savedCategories {
                ForEach(savedCategories.filter { $0.isConstant }, id: \.self) { category in
                    CustomTransactionElementView(
                        selectedCategory: $selectedCategory,
                        selectedPlan: $selectedPlan,
                        category: category.toCustomCategoryType()
                    )
                }
            }else{
                EmptyView()
            }
        }
    }
    private func ForEachTemporaryCustom() -> some View{
        ForEach(customCategoriesFilteredTemporary, id: \.self) { category in
            CustomTransactionElementView(
                selectedCategory: $selectedCategory,
                selectedPlan: $selectedPlan,
                category: category
            )
        }
    }
    private func ForEachTemporarySaved() -> some View{
        Group{
            if let savedCategories = savedCategories {
                ForEach(savedCategories.filter { !$0.isConstant }, id: \.self) { category in
                    CustomTransactionElementView(
                        selectedCategory: $selectedCategory,
                        selectedPlan: $selectedPlan,
                        category: category.toCustomCategoryType()
                    )
                }
            }else{
                EmptyView()
            }
        }
    }
    private func ForEachSavingsCustom() -> some View{
        ForEach(customCategoriesFilteredConstant, id: \.self) { category in
            CustomTransactionElementView(
                selectedCategory: $selectedCategory,
                selectedPlan: $selectedPlan,
                category: category
            )
        }
    }
    private func ForEachSavingsSaved() -> some View {
        Group {
            if let savedCategories = savedCategories {
                ForEach(savedCategories.filter { $0.categoryType == "Сбережения" }, id: \.self) { category in
                    CustomTransactionElementView(
                        selectedCategory: $selectedCategory,
                        selectedPlan: $selectedPlan,
                        category: category.toCustomCategoryType()
                    )
                }
            } else {
                EmptyView()
            }
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                Steps()
                
                StepName()
                
                LazyVStack(alignment: .leading) {
                    if selectedCategory != "Сбережения" {
                        Section(header: Text("Постоянные \(customCategoriesFilteredConstant.count + (savedCategories?.filter { $0.isConstant }.count ?? 0))")) {
                            
                            ForEachConstantCustom()
                            
                            ForEachConstantSaved()
                        }
                        
                        Section(header: Text("Переменные \(customCategoriesFilteredTemporary.count + (savedCategories?.filter { !$0.isConstant }.count ?? 0))")) {
                            
                            ForEachTemporaryCustom()
                            
                            ForEachTemporarySaved()
                        }
                    } else {
                        ForEachSavingsCustom()
                        
                        ForEachSavingsSaved()
                    }
                    
                    ActionDissmisButtons(
                        action: action,
                        actionTitle: "Добавить категорию"
                    ).onTapGesture {
                        logButtonTap()
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(navigationTitle)
        .onAppear {
            setupNavigationTitle()
            filterCategories()
        }
        .hideBackButton()
    }
    
    private func filterCategories() {
        if selectedCategory != "Сбережения" {
            self.customCategoriesFilteredConstant = CustomCategoryType.allCases.filter { $0.displayIsConstant && $0.displayCategory == selectedCategory }
            self.customCategoriesFilteredTemporary = CustomCategoryType.allCases.filter { !$0.displayIsConstant && $0.displayCategory == selectedCategory }
        } else {
            self.customCategoriesFilteredConstant = CustomCategoryType.allCases.filter { $0.displayCategory == selectedCategory }
        }
    }
    
    private func setupNavigationTitle() {
        switch selectedCategory {
        case "Доходы":
            self.navigationTitle = "\(selectedPlan != "План" ? "Запись" : "Планирование") дохода"
        case "Расходы":
            self.navigationTitle = "\(selectedPlan != "План" ? "Запись" : "Планирование") расхода"
        default:
            self.navigationTitle = "\(selectedPlan != "План" ? "Запись" : "Планирование") сбережений"
        }
    }
    
    private func logCategorySelection(_ categoryName: String) {
        let additionalData: [String: Any] = [
            "element": "Category_Row",
            "category": categoryName,
        ]
        
        FirebaseAnalyticsManager.shared.logUserActionEvent(
            userId: getDeviceIdentifier(),
            actionType: "picked",
            screenName: "CreateTransactionSelectCategoryView",
            additionalData: additionalData
        )
    }
    
    private func logButtonTap() {
        let additionalData: [String: Any] = [
            "element": "action_dissmiss_button",
        ]
        
        FirebaseAnalyticsManager.shared.logUserActionEvent(
            userId: getDeviceIdentifier(),
            actionType: "tapped",
            screenName: "CreateTransactionSelectCategoryView",
            additionalData: additionalData
        )
    }
    
    private func action() {
        
    }
    
    private func image(for category: CustomCategoryType) -> String {
        return category.displayName
    }
}

struct CustomTransactionElementView: View {
    @Binding var selectedCategory: String
    @Binding var selectedPlan: String
    let category: CustomCategoryType
    
    var body: some View{
        NavigationLink(destination: CreateTransactionMainView(
            categoryName: category.displayCategory,
            sectionName: selectedCategory,
            selectedPlan: selectedPlan
        )) {
            CategoryRow(
                categoryName: category.displayName,
                imageName: image(for: category)
            ).onTapGesture {
                
            }
        }
    }
}
