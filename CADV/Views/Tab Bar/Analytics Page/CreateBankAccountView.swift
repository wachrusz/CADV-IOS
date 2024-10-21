//
//  CreateBankAccountView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 21.10.2024.
//

import SwiftUI

struct CreateBankAccountView: View {
    @State private var bankAccountName: String = ""
    @State private var bankAccountAmount: String = ""
    @State private var selectedCategory: BankAccountsGroup? = nil
    @Binding var bankAccounts: BankAccounts
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(alignment: .leading,spacing: 20) {
                    Text("Создать новый счет")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .lineSpacing(20)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        TextField("", text: $bankAccountName)
                            .placeholder(when: bankAccountName.isEmpty) {
                                Text("Название счета")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                            }
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(10)
                            .frame(width: 300, height: 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("₽")
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                            .cornerRadius(10)
                            .frame(alignment: .center)
                        
                        TextField("", text: $bankAccountAmount)
                            .placeholder(when: bankAccountName.isEmpty) {
                                Text("00.00")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                            }
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                            .frame(width: 240, height: 40)
                        
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                        Picker("Выберите категорию", selection: $selectedCategory) {
                            ForEach(BankAccountsGroup.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category as BankAccountsGroup?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                        .cornerRadius(10)
                        .frame(width: 300, height: 40)
                        .frame(maxWidth: .infinity, alignment: .center)


                    HStack(alignment: .top, spacing: 20) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Назад")
                                .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                .lineSpacing(20)
                                .foregroundColor(.black)
                        }
                        .padding(EdgeInsets(top: 11, leading: 15, bottom: 9, trailing: 15))
                        .frame(height: 40)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1))

                        Button(action: {
                            validateAndAddGoal()
                        }) {
                            Text("Создать")
                                .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                .lineSpacing(20)
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .frame(height: 40)
                        .background(Color(red: 0.53, green: 0.19, blue: 0.53))
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .offset(y: 20)
            }

            if showErrorPopup {
                VStack {
                    Text(errorMessage)
                        .font(Font.custom("Inter", size: 14).weight(.semibold))
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 2))
                        .scaleEffect(1.1)
                        .transition(.scale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6))
                    Spacer()
                }
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showErrorPopup = false
                        }
                    }
                }
            }
        }
        .padding(.leading)
        .background(.white)
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }

    private func validateAndAddGoal() {
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

        let newGoal = BankAccount(totalAmount: amount, name: bankAccountName, subAccounts: [])
        bankAccounts.Array.append(newGoal)
        presentationMode.wrappedValue.dismiss()
    }

    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            showErrorPopup = true
        }
    }
}
