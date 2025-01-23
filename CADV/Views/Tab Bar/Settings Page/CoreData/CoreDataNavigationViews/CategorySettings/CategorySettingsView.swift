//
//  CategorySettings.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI
import RealmSwift

struct CategorySettingsView: View{
    @Binding var urlElements: URLElements?
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
                    categories: ["Доходы", "Расходы", "Сбережения"]
                )
                CategorySettingsList(
                    selectedCategory: $selectedCategory,
                    showAddCategoryScreen: $showAddCategoryScreen,
                    urlElements: $urlElements
                )

                NavigationLink(
                    destination: AddCategory(
                        category: $selectedCategory,
                        urlElements: $urlElements,
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
        }
        .hideBackButton()
    }
    
    private func generateNavigationTitleName() -> String {
        switch selectedCategory {
        case "Доходы":
            return "Создать категорию дохода"
        case "Расходы":
            return "Создать категорию расхода"
        case "Сбережения":
            return "Создать категорию сбережений"
        default:
            return "УПС! Что-то пошло не так... Попробуйте еще раз... Пока!"
        }
    }
}

struct CategorySettingsList: View {
    @Binding var selectedCategory: String
    @Binding var showAddCategoryScreen: Bool
    @Binding var urlElements: URLElements?
    
    @State private var customCategoriesFiltered: [CustomCategoryType] = []
    
    private func SectionHeaderConstant() -> some View {
        Text("Постоянные \(customCategoriesFiltered.count + (urlElements?.savedCategories.filter { $0.isConstant }.count ?? 0))")
    }
    
    private func SectionHeaderTemporary() -> some View{
        Text("Переменные \(customCategoriesFiltered.count + (urlElements?.savedCategories.filter { !$0.isConstant }.count ?? 0))")
    }
    
    private func SectionHeaderSavings() -> some View{
        Text("Сбережения \(customCategoriesFiltered.count + (urlElements?.savedCategories.filter { $0.categoryType == "Сбережения" }.count ?? 0))")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if selectedCategory != "Сбережения" {
                        Section(header:
                                SectionHeaderConstant()
                        ) {
                            ForEach(customCategoriesFiltered, id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.displayName,
                                    imageName: category.displayName
                                )
                            }
                            
                            ForEach(urlElements?.savedCategories.filter { $0.isConstant } ?? [], id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.name,
                                    imageName: category.iconName
                                )
                            }
                        }
                        
                        Section(header:
                                    SectionHeaderTemporary()
                        ) {
                            ForEach(customCategoriesFiltered, id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.displayName,
                                    imageName: category.displayName
                                )
                            }
                            
                            ForEach(urlElements?.savedCategories.filter { !$0.isConstant } ?? [], id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.name,
                                    imageName: category.iconName
                                )
                            }
                        }
                    } else {
                        Section(header:
                                    SectionHeaderSavings()
                        ) {
                            ForEach(customCategoriesFiltered, id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.displayName,
                                    imageName: category.displayName
                                )
                            }
                            
                            ForEach(urlElements?.savedCategories.filter { $0.categoryType == "Сбережения" } ?? [], id: \.self) { category in
                                CategoryRow(
                                    categoryName: category.name,
                                    imageName: category.iconName
                                )
                            }
                        }
                    }
                    
                    ActionDissmisButtons(
                        action: showAddCategoryScreenFunction,
                        actionTitle: "Добавить категорию"
                    )
                }
            }
            .onChange(of: selectedCategory) { _ in
                filterCategories()
            }
            .onAppear {
                filterCategories()
            }
        }
    }
    
    func initializeRealm() -> Realm? {
        do {
            return try Realm()
        } catch {
            print("Failed to initialize Realm: \(error)")
            return nil
        }
    }
    
    private func filterCategories() {
        if selectedCategory != "Сбережения" {
            self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayIsConstant && $0.displayCategory == selectedCategory }
        } else {
            self.customCategoriesFiltered = CustomCategoryType.allCases.filter { $0.displayCategory == selectedCategory }
        }
    }
    
    private func showAddCategoryScreenFunction() {
        showAddCategoryScreen = true
    }
}

struct CategoryRow: View {
    let categoryName: String
    let imageName: String
    let font: Font = Font.custom("Gilroy", size: 16).weight(.semibold)

    var body: some View {
        HStack(alignment: .center, spacing: 5){
            Image(imageName)
                .resizable()
                .frame(width: 40,height: 40)
            CustomText(
                text: categoryName,
                font: font,
                color: Color("fg")
            )
            Spacer()
        }
        .background(Color("bg1"))
        .padding(.horizontal)
        .cornerRadius(15)
    }
}
