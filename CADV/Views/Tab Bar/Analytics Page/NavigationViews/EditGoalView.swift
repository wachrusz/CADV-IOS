//
//  EditGoalView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 09.10.2024.
//

import SwiftUI

struct EditGoalView: View {
    @State private var goalName: String
    @State private var goalAmount: String
    @State private var goalTime: String
    @Binding var goals: [Goal]
    var goal: Goal
    @Binding var currency: String
    @Binding var tokenData: TokenData

    @Environment(\.presentationMode) var presentationMode
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    @State private var showNameTextFieldError: Bool = false
    @State private var showAmountTextFieldError: Bool = false
    @State private var showTimeTextFieldError: Bool = false
    @State private var isAmountFieldFine: Bool = false
    @State private var isTimeFieldFine: Bool = false
    @State private var isNameFieldFine: Bool = false

    init(goal: Goal,
         goals: Binding<[Goal]>,
         currency: Binding<String>,
         tokenData: Binding<TokenData>
    ) {
        self.goal = goal
        self._goalName = State(initialValue: goal.GoalName)
        self._goalAmount = State(initialValue: String(goal.Need))
        if let endDate = stringToDate(goal.EndDate) {
            let month = Calendar.current.component(.month, from: endDate)
            self._goalTime = State(initialValue: String(month))
        } else {
            self._goalTime = State(initialValue: "0")
        }
        self._goals = goals
        self._currency = currency
        self._tokenData = tokenData
        print(".sheet, goal: \(goal)")
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack() {
                    CustomText(
                        text: "Редактировать цель",
                        font: Font.custom("Inter", size: 16).weight(.semibold),
                        color: Color("fg")
                    )
                    .padding(.vertical)
                    VStack(alignment: .leading){
                        CustomText(
                            text: "Название цели",
                            font: Font.custom("Inter", size: 12).weight(.semibold),
                            color: Color("fg")
                        )
                        
                        CustomTextField(
                            input: $goalName,
                            text: "Нажмите, чтобы ввести",
                            showTextFieldError: $showNameTextFieldError,
                            isFine: $isNameFieldFine
                        )
                        
                        CustomText(
                            text: "Размер цели в основной валюте",
                            font: Font.custom("Inter", size: 12).weight(.semibold),
                            color: Color("fg")
                        )
                        
                        HStack(alignment: .top, spacing: 10) {
                            CustomText(
                                text: currencyCodeToSymbol(code: currency),
                                font: Font.custom("Inter", size: 14).weight(.semibold),
                                color: Color("sc2")
                            )
                            .padding()
                            .frame(maxWidth: 60)
                            .background(Color("bg2"))
                            .cornerRadius(15)
                            
                            CustomTextField(
                                input: $goalAmount,
                                text: "00.00",
                                showTextFieldError: $showAmountTextFieldError,
                                isFine: $isAmountFieldFine
                            )
                            .keyboardType(.decimalPad)
                        }
                        CustomText(
                            text: "Планируемое время достижения в месяцах:",
                            font: Font.custom("Inter", size: 12).weight(.semibold),
                            color: Color("fg")
                        )
                        
                        CustomTextField(
                            input: $goalTime,
                            text: "0",
                            showTextFieldError: $showTimeTextFieldError,
                            isFine: $isTimeFieldFine
                        )
                        .keyboardType(.numberPad)
                        
                        ActionDissmisButtons(
                            action: validateAndUpdateGoal,
                            actionTitle: "Редактировать"
                        )
                        .padding(.top)
                    }
                }
            }
            .padding(.horizontal)
            
            ErrorPopUp(
                showErrorPopup: $showErrorPopup,
                errorMessage: errorMessage
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }
    
    private func validateAndUpdateGoal() {
        if goalName.isEmpty {
            showError(message: "Название не должно быть пустым")
            return
        }
        
        guard let amount = Double(goalAmount), amount > 0 else {
            showError(message: "Сумма должна быть больше 0")
            return
        }
        
        guard let time = Int(goalTime), time >= 1 else {
            showError(message: "Время должно быть не меньше 1 месяца")
            return
        }
        
        guard let startDate = stringToDate(goal.StartDate),
              let endDate = Calendar.current.date(byAdding: .month, value: time, to: startDate) else {
            showError(message: "Не удалось рассчитать конечную дату")
            return
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        let goalNameString = goalName.replacingOccurrences(of: " ", with: "")
        
        abstractFetchData(
            endpoint: "v1/tracker/goal",
            method: "PUT",
            parameters: Goal(
                CurrentState: goal.CurrentState,
                StartDate: startDateString,
                EndDate: endDateString,
                GoalName: goalName,
                ID: goal.ID,
                Need: amount,
                UserID: goal.UserID,
                Currency: currency
            ).toDictionary(),
            headers: [
                "accept" : "application/json",
                "Content-Type": "application/json",
                "Authorization" : tokenData.accessToken
            ]
        ){ result in
            switch result {
            case .success(let responseObject):
                switch responseObject["status_code"] as? Int {
                case 200:
                    print(responseObject)
                default:
                    print("Failed to fetch goals.")
                }
                
            case .failure(let error):
                print("Another yet error: \(error)")
            }
        }

        presentationMode.wrappedValue.dismiss()
    }

    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            showErrorPopup = true
        }
    }
}

