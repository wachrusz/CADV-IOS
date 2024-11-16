//
//  ChangePasswordView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.11.2024.
//

import SwiftUI

struct ChangePasswordView: View {
    @Binding var email: String
    @Binding var token: String
    
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSecureFieldError: Bool = false
    @State private var isFine: Bool = false
    @State private var password: String = ""
    @State private var isCompleted: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    HStack{
                        StepView(number: "1", currentStep: 3, stepIndex: 1)
                        StepView(number: "2", currentStep: 3, stepIndex: 2)
                        StepView(number: "3", currentStep: 3, stepIndex: 3)
                    }
                    .padding(.top)
                    CustomText(
                        text: "Новый пароль",
                        font: Font.custom("Inter", size: 12).weight(.semibold),
                        color: Color("fg")
                    )
                    .padding(.bottom)
                    
                    VStack(alignment: .leading){
                        CustomText(
                            text: "Придумайте пароль",
                            font: Font.custom("Inter", size: 16).weight(.semibold),
                            color: Color("fg")
                        )
                        CustomSecureField(
                            input: $password,
                            showSecureFieldError: $showSecureFieldError,
                            isFine: $isFine,
                            errorMessage: $errorMessage
                        )
                    }
                    CustomText(
                        text: "Используйте цифры, буквы A-z и знак «_»",
                        font: Font.custom("Inter", size: 12).weight(.semibold),
                        color: Color("sc2")
                    )
                    
                    AuthActionButton(
                        action: resetPassword,
                        actionTitle: "Войти в аккаунт"
                    )
                    
                    Spacer()
                    
                }
            }
            .padding(.horizontal)
            
            ErrorPopUp(
                showErrorPopup: $showErrorPopup,
                errorMessage: errorMessage
            )
        }
        .onChange(of: isCompleted) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
    private func resetPassword() {
        guard !password.isEmpty else {
            showErrorPopup.toggle()
            errorMessage = "Пароль не может быть пустым"
            return
        }
        if isFine {
            let passwordString: String = password
            
            let parameters = [
                "email": email,
                "password": passwordString,
                "reset_token": token
            ]
            
            print("Parameters being sent: \(parameters)")
            
            abstractFetchData(
                endpoint: "v1/auth/password",
                method: "PUT",
                parameters: parameters,
                headers: ["Content-Type": "application/json", "accept" : "application/json"]
            ) { result in
                switch result {
                case .success(let responseObject):
                    switch responseObject["status_code"] as? Int{
                    case 200:
                        print(responseObject)
                        self.isCompleted = true
                    case 400:
                        errorMessage = "Кажется, Вы что-то не так ввели"
                        showErrorPopup = true
                    default:
                        errorMessage = "Упс... Что-то пошло не так..."
                        showErrorPopup = true
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Request error: \(error.localizedDescription)")
                        errorMessage = "Упс... Что-то пошло не так..."
                        showErrorPopup = true
                    }
                }
            }
        }
        
    }
}
