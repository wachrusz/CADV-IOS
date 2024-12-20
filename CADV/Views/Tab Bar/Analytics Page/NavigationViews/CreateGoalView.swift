//
//  CreateGoalView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 03.10.2024.
//

import SwiftUI

struct CreateGoalView: View {
    @State private var goalName: String = ""
    @State private var goalAmount: String = ""
    @State private var goalTime: String = ""
    @Binding var goals: [Goal]
    @Binding var currency: String
    @Binding var urlElements: URLElements?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    @State private var isNameFieldFine: Bool = false
    @State private var showNameTextFieldError: Bool = false
    @State private var showAmountTextFieldError: Bool = false
    @State private var showTimeTextFieldError: Bool = false
    @State private var isAmountFieldFine: Bool = false
    @State private var isTimeFieldFine: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack() {
                    CustomText(
                        text: "Создать цель",
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
                            action: validateAndAddGoal,
                            actionTitle: "Создать"
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
        .background(.white)
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }

    private func validateAndAddGoal() async {
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
        
        let startDate = Date()
        guard let endDate = Calendar.current.date(byAdding: .month, value: time, to: startDate) else {
            showError(message: "Не удалось рассчитать конечную дату")
            return
        }

        let dateFormatter = ISO8601DateFormatter()
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        let parameters: [String: Any] = [
            "goal":[
                "goal": goalName,
                "need": amount,
                "currency": currency,
                "current_state": 0,
                "start_date": startDateString,
                "end_date": endDateString
            ]
        ]
        do{
            let response = try await urlElements?.fetchData(
                endpoint: "v1/tracker/goal",
                method: "POST",
                parameters: parameters,
                needsAuthorization: true
            )
            switch response?["status_code"] as? Int {
            case 201:
                print(response)
                presentationMode.wrappedValue.dismiss()
            default:
                print("Failed to fetch goals.")
            }
        }catch let error{
            print(error, separator: "\n", terminator: "\n")
            showError(message: "Упс, что-то пошло не так")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            showErrorPopup = true
        }
    }
}

struct GoalPreview: View{
    var imageName: String
    @Binding var name: String
    var subtext: String
    @Binding var currency: String
    @Binding var amount: String
    var amountText: String = "0"
    var body: some View{
        HStack{
            HStack{
                Image(imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                if name.isEmpty{
                    Text("Название")
                }else{
                    Text(name)
                }
            }
            .frame(alignment: .leading)
            HStack{
                Text(amountText)
            }
            .frame(idealWidth: 300,alignment: .trailing)
        }
    }
}
