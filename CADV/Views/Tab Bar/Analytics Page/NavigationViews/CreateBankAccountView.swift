//
//  CreateBankAccountView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 21.10.2024.
//

import SwiftUI

struct CreateBankAccountView: View {
    @Binding var bankAccounts: BankAccounts
    @Binding var currency: String
    @Binding var tokenData: TokenData
    
    @Environment(\.dismiss) var dismiss
    @State private var bankAccountName: String = ""
    @State private var bankAccountAmount: String = ""
    @State private var selectedCategory: BankAccountsGroup? = .bank
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    @State private var showNameTextFieldError: Bool = false
    @State private var showAmountTextFieldError: Bool = false
    @State private var showTimeTextFieldError: Bool = false
    @State private var isAmountFieldFine: Bool = false
    @State private var isTimeFieldFine: Bool = false
    @State private var isNameFieldFine: Bool = false

    var body: some View {
        NavigationView{
            ZStack {
                GeometryReader { geometry in
                    VStack() {
                        CustomText(
                            text: "Создать новый счет",
                            font: Font.custom("Gilroy", size: 16).weight(.semibold),
                            color: Color("fg")
                        )
                        .padding(.vertical)
                        VStack(alignment: .leading){
                            CustomTextField(
                                input: $bankAccountName,
                                text: "Название счета",
                                showTextFieldError: $showNameTextFieldError,
                                isFine: $isNameFieldFine
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
                                    input: $bankAccountAmount,
                                    text: "00.00",
                                    showTextFieldError: $showAmountTextFieldError,
                                    isFine: $isAmountFieldFine
                                )
                                .keyboardType(.decimalPad)
                            }
                            
                            NavigationLink(destination: BankAccountCategorySelectionView(selectedCategory: $selectedCategory)) {
                                HStack {
                                    Text("Выберите группу счетов")
                                        .foregroundColor(Color("fg"))
                                    Spacer()
                                    Text(selectedCategory?.rawValue ?? "")
                                        .foregroundColor(Color.gray)
                                }
                                .padding()
                                .background(Color("bg1"))
                                .cornerRadius(15)
                            }
                            
                            
                            ActionDissmisButtons(
                                action: validateAndAddBankAccount,
                                actionTitle: "Создать"
                            )
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
        }
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }

    private func validateAndAddBankAccount() async{
        if bankAccountName.isEmpty {
            showError(message: "Название не должно быть пустым")
            return
        }
        
        guard let amount = Double(bankAccountAmount), amount > 0 else {
            showError(message: "Сумма должна быть больше 0")
            return
        }
        
        guard let group = selectedCategory else {
            showError(message: "Вы не выбрали категорию")
            return
        }

        let parameters = [
            "account_number": generateRandomDate(),
            "account_type": selectedCategory?.rawValue ?? "",
            "bank_id": "0",
            "id": "",
            "user_id": ""
        ]
        do{
            let response = try await abstractFetchData(
                endpoint: "v1/app/accounts",
                method: "POST",
                parameters: parameters,
                headers: [
                    "accept" : "application/json",
                    "Content-Type": "application/json",
                    "Authorization" : tokenData.accessToken
                ]
            )
            switch response["status_code"] as? Int{
            case 201:
                dismiss()
            default:
                print(response)
                //showError(message: "oioioi")
            }
        }catch{
            showError(message: "Упс... что-то пошло не так")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            showErrorPopup = true
        }
    }
}

func generateRandomString(length: Int = 20) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?/;:][{}+=-_<>?!@#$%^&*"
    return String((0..<length).compactMap { _ in characters.randomElement() })
}
