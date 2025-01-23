//
//  CreateTransactionView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.11.2024.
//

import SwiftUI

struct CreateTransactionMainView: View {
    var categoryName: String
    var sectionName: String
    var selectedPlan: String
    @State private var planned: Bool = false
    @State private var transactionAmmount: String = "0.0"
    @State private var showAmountTextFieldError: Bool = false
    @State private var isAmountFieldFine: Bool = false
    
    var body: some View {
        VStack{
            HStack(alignment: .center, spacing: 20){
                StepView(number: "1", currentStep: 2, stepIndex: 1)
                StepView(number: "2", currentStep: 2, stepIndex: 2)
            }
            //PREVIEW
            
            if planned{
                HStack(alignment: .top, spacing: 10) {
                    CustomText(
                        text: currencyCodeToSymbol(code: URLElements.shared.currency),
                        font: Font.custom("Inter", size: 14).weight(.semibold),
                        color: Color("sc2")
                    )
                    .padding()
                    .frame(maxWidth: 60)
                    .background(Color("bg2"))
                    .cornerRadius(15)
                    
                    CustomTextField(
                        input: $transactionAmmount,
                        text: "Размер цели",
                        showTextFieldError: $showAmountTextFieldError,
                        isFine: $isAmountFieldFine
                    )
                    .keyboardType(.decimalPad)
                }
            }
            
        }
        .onAppear {
            planned = selectedPlan == "План"
        }
    }
}
