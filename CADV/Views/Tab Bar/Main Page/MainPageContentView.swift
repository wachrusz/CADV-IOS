//
//  MainPageContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import SwiftUI

struct MainPageView: View {
    @State private var profile = ProfileInfo(Surname: "", Name: "", UserID: "", AvatarURL: "")
    @State private var incomes = Incomes(FactArray: [], PlanArray: [])
    @State private var expenses = Expenses(FactArray: [], PlanArray: [])
    @State private var wealthFund = WealthFunds(PlanArray: [], FactArray: [])
    @State private var isSummaryExpanded: Bool = false
    @State private var selectedCategory: String = "Доходы"
    @State private var selectedPlan: String = "Факт"
    @State private var pageIndex: Int = 0
    @State private var isDataFetched: Bool = false
    @State private var isAddingBank = false

    func fetchData() {
        profile = ProfileInfo.GetProfileInfo()
        incomes.GetIncomes()
        expenses.GetExpenses()
        wealthFund.GetWealthFunds()
    }

    var body: some View {
        GeometryReader { geometry in
            Color.white
                .edgesIgnoringSafeArea(.all)
                VStack(spacing: 30) {
                    userProfileSection()
                    incomeExpenseButtons()
                    
                    amountDisplay()
                    
                    factPlanButtons()
                    summarySection()
                    actionButtons()
                }
                .padding(.bottom)
                .background(Color.white)
                .hideBackButton()
                .onAppear {
                    if !isDataFetched {
                        fetchData()
                        isDataFetched = true
                    }
                }
        }
    }

    // User Profile Section
    private func userProfileSection() -> some View {
        HStack(spacing: 20) {
            profileImageAndInfo()
            
            Spacer()
            
            Text(Date().monthDayString())
                .font(.custom("Inter", size: 14).weight(.semibold))
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 3))
        }
        .padding(.horizontal)
    }

    private func profileImageAndInfo() -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: profile.AvatarURL))
                .aspectRatio(contentMode: .fill)
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .foregroundColor(.black)
            
            VStack(alignment: .leading) {
                Text("\(profile.Surname)\n\(profile.Name)")
                    .font(.custom("Gilroy", size: 14).weight(.bold))
                    .foregroundColor(.black)
            }.frame(maxWidth: .infinity)
        }
        .frame(height: 45)
    }

    // Income, Expense, Wealth Buttons
    private func incomeExpenseButtons() -> some View {
        ScrollView(.horizontal) { // Enable horizontal scrolling
            HStack(spacing: 10) {
                ForEach(["Доходы", "Расходы", "Фонд благосостояния"], id: \.self) { category in
                    incomeExpenseButton(text: category, isSelected: selectedCategory == category)
                        .onTapGesture {
                            selectedCategory = category
                            pageIndex = 0
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    // Amount Display
    private func amountDisplay() -> some View {
        HStack(spacing: 0) {
            Text("₽")
                .font(.custom("Inter", size: 36).weight(.semibold))
                .foregroundColor(Color.gray)
            Text(totalAmount(for: selectedCategory))
                .font(.custom("Inter", size: 45).weight(.bold))
                .foregroundColor(.black)
        }
        .frame(height: 85)
        .padding(.horizontal)
    }

    // Fact and Plan Buttons
    private func factPlanButtons() -> some View {
        HStack(spacing: 10) {
            ForEach(["Факт", "План"], id: \.self) { plan in
                factPlanButton(text: plan, isSelected: selectedPlan == plan)
                    .onTapGesture {
                        selectedPlan = plan
                    }
            }
        }
        .frame(height: 35)
        .padding(.horizontal)
    }

    // Summary Section
    private func summarySection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                withAnimation(.easeInOut) {
                    isSummaryExpanded.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: isSummaryExpanded ? 25 : 10)
                        .fill(isSummaryExpanded ? Color.black : Color.white)
                        .frame(width: isSummaryExpanded ? 50 : 100, height: 50)
                        .animation(.bouncy, value: isSummaryExpanded)
                    Text(isSummaryExpanded ? "-" : "Резюме")
                        .font(.custom("Gilroy", size: isSummaryExpanded ? 30 : 20).weight(.bold))
                        .foregroundColor(isSummaryExpanded ? .white : .black)
                }
            }
            .frame(width: 350, alignment: .leading)

            if isSummaryExpanded {
                TabView {
                    ForEach(0..<getNumberOfPages(), id: \.self) { pageIndex in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                switch selectedCategory {
                                case "Доходы":
                                    ForEach(getPageItems(items: selectedPlan == "Факт" ? incomes.FactArray : incomes.PlanArray, pageIndex: pageIndex), id: \.ID) { income in
                                        summaryItem(title: "Income", amount: "+ ₽ \(formattedTotalAmount(amount: income.Amount))", details: "Перевод", detailAmount: "\(income.IncomeDate)", color: Color(red: 0.22, green: 0.49, blue: 0.21))
                                    }
                                case "Расходы":
                                    ForEach(getPageItems(items: selectedPlan == "Факт" ? expenses.FactArray : expenses.PlanArray, pageIndex: pageIndex), id: \.ID) { expense in
                                        summaryItem(title: "Expense", amount: "- ₽ \(formattedTotalAmount(amount: expense.Amount))", details: "Перевод", detailAmount: "\(expense.ExpenseDate)", color: Color(red: 0.22, green: 0.49, blue: 0.21))
                                    }
                                case "Фонд благосостояния":
                                    ForEach(getPageItems(items: selectedPlan == "Факт" ? wealthFund.FactArray : wealthFund.PlanArray, pageIndex: pageIndex), id: \.ID) { fund in
                                        summaryItem(title: "Wealth Fund", amount: "₽ \(formattedTotalAmount(amount: fund.Amount))", details: "Перевод", detailAmount: "\(fund.WealthFundDate)", color: Color(red: 0.22, green: 0.49, blue: 0.21))
                                    }
                                default:
                                    EmptyView()
                                }
                            }
                            .padding()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 250)
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }

    // Helper function to calculate the number of pages
    private func getNumberOfPages() -> Int {
        let itemsCount = selectedCategory == "Доходы" ? (selectedPlan == "Факт" ? incomes.FactArray.count : incomes.PlanArray.count)
                        : selectedCategory == "Расходы" ? (selectedPlan == "Факт" ? expenses.FactArray.count : expenses.PlanArray.count)
                        : (selectedPlan == "Факт" ? wealthFund.FactArray.count : wealthFund.PlanArray.count)
        return Int(ceil(Double(itemsCount) / 20.0))
    }

    // Helper function to retrieve items for the current page
    private func getPageItems<T: Identifiable>(items: [T], pageIndex: Int) -> [T] {
        let startIndex = pageIndex * 20
        let endIndex = min(startIndex + 20, items.count)
        return Array(items[startIndex..<endIndex])
    }

    // Action Buttons
    private func actionButtons() -> some View {
        HStack(spacing: 20) {
            actionButton(text: "Добавить банк", textColor: .white, backgroundColor: .black){
                isAddingBank = true
            }.sheet(isPresented: $isAddingBank){
                AddBankAccountView()
            }
            actionButton(text: "Внести вручную", textColor: .black, backgroundColor: Color(red: 0.94, green: 0.94, blue: 0.94)){
                
            }
        }
        .padding(.horizontal)
    }

    // Custom Button Functions
    private func incomeExpenseButton(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.custom("Gilroy", size: 14).weight(.semibold))
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(isSelected ? .black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(15)
    }

    private func factPlanButton(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.custom("Gilroy", size: 14).weight(.semibold))
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .frame(idealWidth: 65)
            .background(isSelected ? Color.black : Color.white)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.black.opacity(0.1), lineWidth: 1))
    }

    private func actionButton(text: String, textColor: Color, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action){
            Text(text)
                .font(.custom("Inter", size: 14).weight(.semibold))
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }

    // Summary Item
    private func summaryItem(title: String, amount: String, details: String, detailAmount: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 5) {
            AsyncImage(url: URL(string: "https://via.placeholder.com/32x32"))
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .cornerRadius(5)
                .background(Color.gray).opacity(0.1)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(title)
                        .font(.custom("Gilroy", size: 16).weight(.semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Text(amount)
                        .font(.custom("Inter", size: 16).weight(.semibold))
                        .foregroundColor(color)
                }
                HStack {
                    Text(details)
                        .font(.custom("Inter", size: 14).weight(.semibold))
                        .foregroundColor(Color.gray)
                    Spacer()
                    Text(detailAmount)
                        .font(.custom("Inter", size: 14).weight(.semibold))
                        .foregroundColor(Color.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(5)
            .shadow(radius: 0.5)
        }
    }
    
    private func totalAmount(for category: String) -> String {
        switch category {
        case "Доходы":
            return selectedPlan == "Факт" ? 
            formattedTotalAmount(amount: incomes.totalFactAmount()) :
            formattedTotalAmount(amount: incomes.totalPlanAmount())
        case "Расходы":
            return selectedPlan == "Факт" ? 
            formattedTotalAmount(amount: expenses.totalFactAmount()) :
            formattedTotalAmount(amount: expenses.totalPlanAmount())
        case "Фонд благосостояния":
            return selectedPlan == "Факт" ? 
            formattedTotalAmount(amount: wealthFund.totalFactAmount()) :
            formattedTotalAmount(amount: wealthFund.totalPlanAmount())
        default:
            return formattedTotalAmount(
                amount: incomes.totalFactAmount()+wealthFund.totalFactAmount()-expenses.totalFactAmount())
        }
    }
    
    func formattedTotalAmount(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        }
        return "\(amount)"
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
            .preferredColorScheme(.light)
    }
}
