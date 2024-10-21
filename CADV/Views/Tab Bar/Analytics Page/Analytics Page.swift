//
//  Analytics Page.swift
//  CADV
//
//  Created by Misha Vakhrushin on 01.10.2024.
//

import SwiftUI

struct AnalyticsPageView: View {
    @State private var profile = ProfileInfo(Surname: "", Name: "", UserID: "", AvatarURL: "")
    @State private var goals = Goals(Array: [])
    @State private var annualPayments = AnnualPayments(Array: [])
    @State private var transactions = Transactions(Array: [])
    @State private var bankAccounts = BankAccounts(Array: [])
    @State private var isSummaryExpanded: Bool = false
    @State private var selectedCategory: String = "Состояние"
    @State private var selectedPlan: String = "Транзакции"
    @State private var pageIndex: Int = 0
    @State private var contentHeight: CGFloat = 0
    @State private var isDataFetched: Bool = false
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

    init(){
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }
    
    func fetchData() {
        profile = ProfileInfo.GetProfileInfo()
        goals.getGoals()
        annualPayments.GetAnnualPayments()
        transactions.getTransactions()
        bankAccounts.getBankAccounts()
        
        isDataFetched = true
    }

    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                Color.white
                    .edgesIgnoringSafeArea(.all)
                    VStack(spacing: 30) {
                        userProfileSection()
                        stateGoalsButtons()
                        switch selectedCategory{
                        case "Состояние":
                            amountDisplay()
                
                            transactionsAccountsButtons()
                            summarySection()
                            if selectedPlan == "Счета"{
                                actionButtons()
                            }
                            
                        case "Цели":
                            dragGoalsView()
                            
                        case "Финансовое Здоровье":
                            finHealthSection()
                            
                        default:
                            amountDisplay()
                
                            transactionsAccountsButtons()
                            summarySection()
                            actionButtons()

                        }
                    }
                    .padding(.bottom)
                    .background(Color.white)
                    .hideBackButton()
                    .onAppear {
                        if !isDataFetched {
                            fetchData()
                            isDataFetched = true
                            print(selectedCategory)
                        }
                    }
                    .sheet(isPresented: Binding<Bool>(
                        get: { isEditing },
                        set: { newValue in
                            withAnimation {
                                isEditing = newValue
                            }
                        })) {
                        if let goal = selectedGoal {
                            EditGoalView(goal: goal, goals: $goals)
                        } else {
                            Text("Ошибка: цель не выбрана.")
                        }
                    }
            }
        }

    }
    
    private func dragGoalsView() -> some View {
        ZStack {
            goalsSection()
                .offset(y: showAnnualPayments ? UIScreen.main.bounds.height + dragOffset.height : dragOffset.height)
            .opacity(showAnnualPayments ? 0 : 1)
            .zIndex(showAnnualPayments ? 0 : 1)
            .animation(.easeInOut, value: dragOffset.height)

            annualPaymentsSection()
            .offset(y: showAnnualPayments ? dragOffset.height : UIScreen.main.bounds.height + dragOffset.height)
            .opacity(showAnnualPayments ? 1 : 0)
            .zIndex(showAnnualPayments ? 1 : 0)
            .animation(.easeInOut, value: dragOffset.height)
        }
        .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = value.translation.height
                        dragOffset.height = min(max(newOffset, -50), 50)
                    }
                    .onEnded { value in
                        withAnimation {
                            if value.translation.height < -100 {
                                feedbackGeneratorMedium.impactOccurred()
                                showAnnualPayments = true
                            } else if value.translation.height > 100 {
                                feedbackGeneratorMedium.impactOccurred()
                                showAnnualPayments = false
                            }
                            dragOffset = .zero
                        }
                    }
            )
            .edgesIgnoringSafeArea(.all)
        .edgesIgnoringSafeArea(.all)
    }

    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 200)
            .onEnded { value in
                print("Движение: \(value.translation.height)")
                withAnimation {
                    if value.translation.height < 0 {
                        showAnnualPayments = true
                        print("Переключение на annualPayments")
                    } else {
                        showAnnualPayments = false
                        print("Переключение на goals")
                    }
                }
            }
    }

    private func annualPaymentsSection() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                Text("Ежемесячные платежи")
                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                    .lineSpacing(15)
                    .foregroundColor(.black)
                
                Text("\(annualPayments.CountCompleted())/\(annualPayments.Array.count)")
                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                    .tracking(1)
                    .lineSpacing(15)
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            }
            switch annualPayments.Array.count {
            case 0:
                Text("Информация о ежемесячных отчислениях для постоянного прогресса в достижении Ваших целей")
                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                    .lineSpacing(15)
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            default:
                TabView {
                    ForEach(0..<getNumberOfPages(itemsArray: annualPayments.Array), id: \.self) { pageIndex in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                ForEach(getPageItems(items: annualPayments.Array, pageIndex: pageIndex), id: \.ID) { payment in
                                    annualPaymentsItem(title: payment.name, totalAmount:  payment.amount, detailAmount: payment.date, color: Color(red: 0.22, green: 0.49, blue: 0.21), paidAmount: payment.paidAmount)
                                    .padding()
                                }
                            }
                            .padding()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(idealHeight: 500)
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }

    private func annualPaymentsItem(title: String, totalAmount: Double, detailAmount: String, color: Color, paidAmount: Double) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Image("edu")
                .resizable()
                .frame(maxWidth: 40, maxHeight: 40)
            
                HStack {
                    Text(title)
                        .font(.custom("Gilroy", size: 16).weight(.semibold))
                        .foregroundColor(.black)
                    
                    VStack {
                        Text("₽ \(formattedTotalAmount(amount: totalAmount))")
                            .font(.custom("Inter", size: 16).weight(.semibold))
                            .foregroundColor(color)
                        
                        GeometryReader { geometry in
                            let progress = min(max(paidAmount / totalAmount, 0), 1)
                            Rectangle()
                                .fill(color)
                                .frame(width: geometry.size.width * CGFloat(progress), height: 5)
                                .cornerRadius(2.5)
                        }
                        .frame(height: 5)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(2.5)
                    }
            }
        }
        .padding()
        .background(Color.white)
    }


    
    private func finHealthSection() -> some View{
        VStack{
            
        }
    }
    
    private func addGoalButton() -> some View {
        NavigationLink(destination: CreateGoalView(goals: $goals)) {
            VStack(spacing: 10) {
                Image("goalIcon")
                    .resizable()
                    .frame(width: 75, height: 75)
                
                Text("Создать новую цель")
                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                    .foregroundColor(.black)
                
                Text("Нажмите, чтобы продолжить")
                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            }
            .frame(maxWidth: 200, maxHeight: 305)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(20)
            .contentShape(Rectangle())
        }
    }
    
    private func getNumberOfPages(itemsPerPage: Int = 20, itemsArray: [Any]) -> Int {
        return (itemsArray.count + itemsPerPage - 1) / itemsPerPage
    }
    
    private func getPageItems(items: [AnnualPayment], pageIndex: Int) -> [AnnualPayment] {
        let startIndex = pageIndex * 20
        let endIndex = min(startIndex + 20, items.count)
        return Array(items[startIndex..<endIndex])
    }
    
    private func goalsView() -> some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(Array(goals.Array.prefix(2))) { goal in
                        VStack(spacing: 5) {
                            HStack(spacing: 5) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 25, height: 25)
                                    .background(
                                        Image("edu")
                                    )
                                Text(goal.GoalName)
                                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                    .lineSpacing(20)
                                    .foregroundColor(.black)
                            }
                            HStack(spacing: 5) {
                                Text("Цель:")
                                    .font(Font.custom("Gilroy", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                                Text("₽ \(goal.Need, specifier: "%.2f")")
                                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                            }
                            
                            ZStack {
                                Circle()
                                    .stroke(
                                        Color(red: 0.95, green: 0.91, blue: 0.95),
                                        lineWidth: 10
                                    )
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: 2 / CGFloat(goal.CurrentState))
                                    .stroke(
                                        Color(red: 0.53, green: 0.19, blue: 0.53),
                                        lineWidth: 10
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150)
                                
                                Text("2/\(goal.CurrentState)")
                                    .font(Font.custom("Inter", size: 36).weight(.semibold))
                                    .foregroundColor(.black)
                            }
                            
                            HStack(spacing: 5) {
                                Text("Платёж:")
                                    .font(Font.custom("Gilroy", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                                Text("₽ 5 000,00")
                                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.53, green: 0.19, blue: 0.53))
                            }
                        }
                        .padding(10)
                        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                        .cornerRadius(20)
                        .frame(width: 200, height: 280)
                        .simultaneousGesture(TapGesture().onEnded {
                            print("Tapped on goal: \(goal.GoalName)")
                        })
                        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
                            isLongPressing = pressing
                        }, perform: {
                            selectedGoal = goal
                            isEditing = true
                            feedbackGeneratorHard.impactOccurred()
                        })
                    }
                    
                    VStack {
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(width: 200, height: 280)
                            .overlay(
                                Text("Показать все")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            )
                            .onTapGesture {
                                print("Переход на вьюшку с отображением всех целей")
                                showAllGoalsView = true
                            }
                    }
                }
                .padding(.horizontal)
                .frame(height: 280)
            }
            .sheet(isPresented: $showAllGoalsView) {
                AllGoalsView(goals: $goals)
            }
            Spacer()
            Text("Свайпните вниз, чтобы посмотреть ежемесячные платежи по целям")
                .padding()
                .foregroundColor(.black)
        }
    }
    
    private func goalsSection() -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 10){
                if goals.Array.isEmpty{
                    Text("Финансовые Цели")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .lineSpacing(15)
                        .foregroundColor(.black)
                }else{
                    Text("Финансовые Цели")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .lineSpacing(15)
                        .foregroundColor(.black)

                    NavigationLink(destination: CreateGoalView(goals: $goals)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.black)
                    }
                    .padding(.trailing)
                }
            }
            
            HStack(spacing: 10) {
                Text("0/\(goals.Array.count)")
                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                    .lineSpacing(15)
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            }
            .padding(.leading)
            
            switch goals.Array.count {
            case 0:
                addGoalButton()  
            default:
                goalsView()
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
    private func stateGoalsButtons() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(["Состояние", "Цели", "Финансовое Здоровье"], id: \.self) { category in
                    stateGoalsButton(text: category, isSelected: selectedCategory == category)
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
            Text(formattedTotalAmount(amount: bankAccounts.TotalAmount))
                .font(.custom("Inter", size: 45).weight(.bold))
                .foregroundColor(.black)
        }
        .frame(height: 85)
        .padding(.horizontal)
    }

    // Fact and Plan Buttons
    private func transactionsAccountsButtons() -> some View {
        HStack(spacing: 10) {
            ForEach(["Транзакции", "Счета"], id: \.self) { plan in
                transactionsAccountsButton(text: plan, isSelected: selectedPlan == plan)
                    .onTapGesture {
                        selectedPlan = plan
                    }
            }
        }
        .frame(height: 35)
        .padding(.horizontal)
    }

    private func transactionElement(transaction: Transaction) -> some View{
        HStack{
            Image("edu")
                .resizable()
                .frame(width: 40,height: 40)
            VStack(alignment: .leading, spacing: 5){
                Text(transaction.name)
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                Text(transaction.category.rawValue)
                    .font(.custom("Gilroy", size: 12).weight(.semibold))
                    .foregroundColor(Color.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            currencyAndAmountText(transaction: transaction)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func currencyAndAmountText(transaction: Transaction) -> some View {
        HStack{
            Text(currencyCodeAndTypeToSymbol(type: transaction.type, code: transaction.currency.rawValue))
                .foregroundColor(transaction.type.rawValue == "Доход" ? Color.green : Color.red)
            Text(formattedTotalAmount(amount: transaction.amount))
                .foregroundColor(Color.black)
        }
    }
    
    private func currencyCodeAndTypeToSymbol(type: TransactionType, code: String) -> String {
        switch code{
        case "RUB":
            return "\(type.rawValue == "Доход" ? "+" : "-")₽"
        case "EUR":
            return "\(type.rawValue == "Доход" ? "+" : "-")€"
        case "USD":
            return "\(type.rawValue == "Доход" ? "+" : "-")$"
        default:
            return "\(type.rawValue == "Доход" ? "+" : "-")₽"
        }
    }
    private func currencyCodeToSymbol(code: String) -> String{
        switch code{
        case "RUB":
            return "₽"
        case "EUR":
            return "€"
        case "USD":
            return "$"
        default:
            return "₽"
        }
    }
    
    private func bankAccountList(bankAccount: BankAccount) -> some View{
        HStack{
            Image(bankAccount.name)
                .resizable()
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 5){
                Text(bankAccount.name)
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                ForEach(bankAccount.subAccounts){subAccount in
                    Text(subAccount.name)
                        .font(.custom("Gilroy", size: 12).weight(.semibold))
                        .foregroundColor(Color.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 5){
                Text(formattedTotalAmount(amount: bankAccount.totalAmount))
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                ForEach(bankAccount.subAccounts){subAccount in
                    Text("\(currencyCodeToSymbol(code: subAccount.currency.rawValue)) \(formattedTotalAmount(amount: subAccount.totalAmount))")
                        .font(.custom("Gilroy", size: 12).weight(.semibold))
                        .foregroundColor(Color.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxHeight: 100)
        .cornerRadius(10)
    }
    
    // Summary Section
    private func summarySection() -> some View {
        ZStack{
            switch selectedPlan{
            case "Транзакции":
                TabView {
                    ForEach(0..<getNumberOfPages(itemsArray: transactions.Array), id: \.self) { pageIndex in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                let groupedTransactions = Dictionary(grouping: transactions, by: { $0.dateObject ?? Date() })
                                ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                                    Section(header: Text(date, style: .date).foregroundColor(Color.black)) {
                                        ForEach(groupedTransactions[date]!) { transaction in
                                            transactionElement(transaction: transaction)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(10)
            //TODO: REDOOOOOO
            case "Счета":VStack {
                if (contentHeight > 150 && !isExpanded) || (contentHeight < 150) {
                    LazyVStack(spacing: 10) {
                        ForEach(bankAccounts) { bankAccount in
                            bankAccountList(bankAccount: bankAccount)
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
                        LazyVStack(spacing: 10) {
                            ForEach(bankAccounts) { bankAccount in
                                bankAccountList(bankAccount: bankAccount)
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
                
                if bankAccounts.isEmpty {
                    VStack {
                        Text("Подключите приложение банка, чтобы данные о ваших финансах учитывались автоматически или добавьте информацию о наличном счете, чтобы учитывать операции с наличными")
                            .padding()
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
            .onAppear {
                if bankAccounts.count == 1 {
                    contentHeight = 50
                }
                print("--------------\n\(Date())\n\(bankAccounts)\n")
            }

            default:
                EmptyView()
            }
        }
    }

    private func actionButtons() -> some View {
        HStack(spacing: 20) {
            actionButton(text: "Добавить банк", textColor: .white, backgroundColor: .black){
                isAddingBank = true
            }
            
            actionButton(text: "Внести вручную", textColor: .black, backgroundColor: Color(red: 0.94, green: 0.94, blue: 0.94)){
                isEnteringManually = true
            }
            .sheet(isPresented: $isEnteringManually) {
                CreateBankAccountView(bankAccounts: $bankAccounts)
            }
        }
        .padding(.horizontal)
    }

    private func stateGoalsButton(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.custom("Gilroy", size: 14).weight(.semibold))
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(isSelected ? .black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(15)
    }

    private func transactionsAccountsButton(text: String, isSelected: Bool) -> some View {
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

 /*
    // Function to calculate total amount based on selected category
    private func totalAmount(for category: String) -> String {
            return formattedTotalAmount(
                amount: incomes.totalFactAmount()+wealthFund.totalFactAmount()-expenses.totalFactAmount())
        }
    }
  */
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

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsPageView()
            .preferredColorScheme(.light)
    }
}
