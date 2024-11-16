//
//  CategorySettings.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI
import CoreData

struct CategorySettingsView: View{
    @Environment(\.managedObjectContext) private var viewContext
    @State private var categories: [CategoryEntity] = []
    
    @State var selectedCategory: String = "Доходы"
    @State var pageIndex: Int = 0
    @State var showAddCategoryScreen: Bool = false
    
    var body: some View{
        NavigationStack{
            VStack(alignment: .center, spacing: 20){
                CommonHeader(
                    image: "CardDivider",
                    headerText: "Настройка категорий",
                    subHeaderText: "Управляйте категориями легко"
                )
                CategorySwitchButtons(
                    selectedCategory: $selectedCategory,
                    pageIndex: $pageIndex,
                    categories: ["Доходы", "Расходы", "Фонд благосостояния"]
                )
                CategorySettingsList(
                    selectedCategory: $selectedCategory,
                    showAddCategoryScreen: $showAddCategoryScreen
                )

                NavigationLink(
                    destination: AddCategory(
                        category: $selectedCategory,
                        navigationTitle: generateNavigationTitleName()
                    ),
                    isActive: $showAddCategoryScreen,
                    label: { EmptyView() }
                )
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .colorScheme(.light)
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
        .hideBackButton()
    }
    
    private func generateNavigationTitleName() -> String {
        switch selectedCategory {
        case "Доходы":
            return "Создать категорию дохода"
        case "Расходы":
            return "Создать категорию расхода"
        case "Фонд благосостояния":
            return "Создать категорию сбережений"
        default:
            return "УПС! Что-то пошло не так... Попробуйте еще раз... Пока!"
        }
    }
}

struct CategorySettingsList: View {
    @Binding var selectedCategory: String
    @Binding var showAddCategoryScreen: Bool
    @State private var customCategoriesFiltered: [CustomCategoryType] = []
    @FetchRequest var savedCategories: FetchedResults<CategoryEntity>

    init(
        selectedCategory: Binding<String>,
        showAddCategoryScreen: Binding<Bool>
    ) {
        self._selectedCategory = selectedCategory
        self._showAddCategoryScreen = showAddCategoryScreen

        let predicate: NSPredicate
        switch selectedCategory.wrappedValue {
        case "Доходы":
            predicate = NSPredicate(format: "categoryType == %@", "Доходы")
        case "Расходы":
            predicate = NSPredicate(format: "categoryType == %@", "Расходы")
        case "Фонд Благосостояния":
            predicate = NSPredicate(format: "categoryType == %@", "Фонд благосостояния")
        default:
            predicate = NSPredicate(value: true)
        }

        _savedCategories = FetchRequest(
            entity: CategoryEntity.entity(),
            sortDescriptors: [],
            predicate: predicate
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                if selectedCategory != "Фонд благосостояния"{
                    Section(header: Text("Постоянные \(customCategoriesFiltered.count + savedCategories.filter { $0.isConstant }.count)")) {
                        ForEach(customCategoriesFiltered, id: \.self) { category in
                            CategoryRow(
                                categoryName: category.displayName,
                                imageName: category.displayName
                            )
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
                            .onAppear(){
                                print("-------------\n\(category.name)\n\(category.categoryType)")
                            }
                        }
                    }
                }
                ActionDissmisButtons(
                    action: showAddCategoryScreenFunction,
                    actionTitle: "Добавить категорию"
                )
            }
        }
        .onChange(of: selectedCategory){
            if selectedCategory != "Фонд благосостояния" {
                self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayIsConstant && $0.displayCategory == selectedCategory }
            } else {
                self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayCategory == selectedCategory }
            }
        }
        .onAppear(){
            if selectedCategory != "Фонд благосостояния" {
                self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayIsConstant && $0.displayCategory == selectedCategory }
            } else {
                self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayCategory == selectedCategory }
            }
        }
    }
    private func showAddCategoryScreenFunction() {
           showAddCategoryScreen = true
    }
}

struct CategoryRow: View {
    let categoryName: String
    let imageName: String

    var body: some View {
        HStack{
            Image(imageName)
                .resizable()
                .frame(width: 40,height: 40)
            Text(categoryName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        
    }
}
