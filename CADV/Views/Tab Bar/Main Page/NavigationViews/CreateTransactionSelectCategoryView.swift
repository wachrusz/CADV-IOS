//
//  CreateTransaction.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.11.2024.
//

import SwiftUI
import CoreData

struct CreateTransactionSelectCategory: View {
    @Binding var selectedCategory: String
    @Binding var selectedPlan: String
    
    @State private var customCategoriesFiltered: [CustomCategoryType] = []
    @FetchRequest var savedCategories: FetchedResults<CategoryEntity>
    
    @State private var navigationTitle: String = ""
    
    init(
        selectedCategory: Binding<String>,
        selectedPlan: Binding<String>
    ) {
        self._selectedCategory = selectedCategory
        self._selectedPlan = selectedPlan
        
        let predicate: NSPredicate
        switch selectedCategory.wrappedValue {
        case "Доходы":
            predicate = NSPredicate(format: "categoryType == %@", "Доходы")
        case "Расходы":
            predicate = NSPredicate(format: "categoryType == %@", "Расходы")
        case "Фонд благосостояния":
            predicate = NSPredicate(format: "categoryType == %@", "Фонд благосостояния")
        default:
            predicate = NSPredicate(value: true)
        }
        
        _savedCategories = FetchRequest(
            entity: CategoryEntity.entity(),
            sortDescriptors: [],
            predicate: predicate
        )
        
        print(selectedCategory.wrappedValue)
    }
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView{
                    HStack(alignment: .center, spacing: 20){
                        StepView(number: "1", currentStep: 1, stepIndex: 1)
                        StepView(number: "2", currentStep: 1, stepIndex: 2)
                    }
                    .padding(.top)
                    CustomText(
                        text: "Выбор категории",
                        font: Font.custom("Gilroy",size: 12).weight(.semibold),
                        color: Color("fg")
                    )
                    .padding(.vertical)
                    
                    LazyVStack(alignment: .leading) {
                        if selectedCategory != "Фонд благосостояния"{
                            Section(header: Text("Постоянные \(customCategoriesFiltered.count + savedCategories.filter { $0.isConstant }.count)")) {
                                ForEach(customCategoriesFiltered, id: \.self) { category in
                                    NavigationLink(destination: CreateTransactionMainView(categoryName: category.displayCategory)
                                    ) {
                                        CategoryRow(
                                            categoryName: category.displayName,
                                            imageName: category.displayName
                                        )
                                    }
                                }
                                
                                ForEach(savedCategories.filter { $0.isConstant }, id: \.self) { category in
                                    if let categoryName = category.name, let imageName = category.iconName {
                                        CategoryRow(
                                            categoryName: categoryName,
                                            imageName: imageName
                                        )
                                    }
                                }
                            }
                            
                            Section(header: Text("Переменные \(customCategoriesFiltered.count + savedCategories.filter { !$0.isConstant }.count)")) {
                                ForEach(customCategoriesFiltered, id: \.self) { category in
                                    CategoryRow(
                                        categoryName: category.displayName,
                                        imageName: category.displayName
                                    )
                                }
                                
                                ForEach(savedCategories.filter { !$0.isConstant }, id: \.self) { category in
                                    if let categoryName = category.name, let imageName = category.iconName {
                                        CategoryRow(
                                            categoryName: categoryName,
                                            imageName: imageName
                                        )
                                    }
                                }
                            }
                        }else{
                            ForEach(customCategoriesFiltered, id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.displayName,
                                    imageName: category.displayName
                                )
                            }
                            ForEach(savedCategories.filter {$0.categoryType == "Фонд благосостояния"}, id: \.self) { category in
                                if let categoryName = category.name, let imageName = category.iconName {
                                    CategoryRow(
                                        categoryName: categoryName,
                                        imageName: imageName
                                    )
                                }
                            }
                        }
                        ActionDissmisButtons(
                            action: action,
                            actionTitle: "Добавить категорию"
                        )
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(navigationTitle)
        .onAppear(){
            switch selectedCategory {
            case "Доходы":
                self.navigationTitle = "\(selectedPlan != "План" ? "Запись" : "Планирование") дохода"
            case "Расходы":
                self.navigationTitle = "\(selectedPlan != "План" ? "Запись" : "Планирование") расхода"
            default:
                self.navigationTitle = "\(selectedPlan != "План" ? "Запись" : "Планирование") сбережений"
            }
            
            if selectedCategory != "Фонд благосостояния" {
                self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayIsConstant && $0.displayCategory == selectedCategory }
            } else {
                self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayCategory == selectedCategory }
            }
        }
    }
    func action(){
        
    }
}
