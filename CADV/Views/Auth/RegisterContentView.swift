//
//  RegisterContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.09.2024.
//

import SwiftUI

struct RegisterView: View{
    @State var email: String = ""
    @State var password: String = ""
    @State var repeatPassword: String = ""
    @State var showEmailVerification: Bool = false
    @State var token: String = ""
    @State private var showTextFieldError: Bool = false
    @State private var showSecureFieldError: Bool = false
    @State private var isTextFieldFine: Bool = false
    @State private var isSecureFieldFine: Bool = false
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    private var screenName: String = "Регистрация"
    
    var body: some View{
        NavigationStack{
            ZStack{
                VStack{
                    HStack(spacing: 20) {
                        StepView(number: "1", currentStep: 1, stepIndex: 1)
                        StepView(number: "2", currentStep: 1, stepIndex: 2)
                    }
                    .padding()
                    
                    
                    CustomText(
                        text: "Ввод данных аккаунта",
                        font: Font.custom("Inter", size: 12).weight(.semibold),
                        color: Color("fg")
                    )
                    .padding(.bottom)
                    
                    VStack{
                        CustomText(
                            text: "Введите свой email",
                            font: Font.custom("Inter", size: 14).weight(.semibold),
                            color: Color("fg")
                        )
                        CustomTextField(
                            input: $email,
                            text: "example@emaple.com",
                            showTextFieldError: $showTextFieldError,
                            isFine: $isTextFieldFine
                            
                        )
                        CustomText(
                            text: "Введите пароль",
                            font: Font.custom("Inter", size: 14).weight(.semibold),
                            color: Color("fg")
                        )
                        CustomSecureField(
                            input: $password,
                            showSecureFieldError: $showSecureFieldError,
                            isFine: $isSecureFieldFine,
                            errorMessage: $errorMessage
                        )
                        CustomText(
                            text: "Повторите пароль",
                            font: Font.custom("Inter", size: 14).weight(.semibold),
                            color: Color("fg")
                        )
                        CustomSecureField(
                            input: $repeatPassword,
                            showSecureFieldError: $showSecureFieldError,
                            isFine: $isSecureFieldFine,
                            errorMessage: $errorMessage
                        )
                    }
                    .padding(.horizontal)
                    
                    CustomText(
                        text: "Используйте цифры, буквы A-z и знак «_»",
                        font: Font.custom("Inter", size: 12).weight(.semibold),
                        color: Color("sc2")
                    )
                    .padding(.horizontal)
                    
                    AuthActionButton(
                        action: register,
                        actionTitle: "Создать аккаунт"
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    NavigationLink(
                        destination: EnterVerificationEmailCode(
                            email: $email,
                            token: $token,
                            isNew: true,
                            previousScreenName: screenName
                        ),
                        isActive: $showEmailVerification,
                        label: {EmptyView()}
                    )
                }
                ErrorPopUp(
                    showErrorPopup: $showErrorPopup,
                    errorMessage: errorMessage
                )
            }
        }
        .colorScheme(.light)
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .navigationTitle(screenName)
    }
    
    private func register() async{
        let parameters = [
            "email": email,
            "password": password
        ]
        do{
            let response = try await abstractFetchData(
                endpoint: "v1/auth/register",
                parameters: parameters,
                headers: ["Content-Type": "application/json", "accept" : "application/json"]
            )
            switch response["status_code"] as? Int{
            case 200:
                token = response["token"] as? String ?? ""
                self.showEmailVerification = true
            case 400:
                errorMessage = "Кажется, Вы что-то не так ввели"
                showErrorPopup = true
            default:
                errorMessage = "Упс... Что-то пошло не так..."
                showErrorPopup = true
            }
        }catch{
            
        }
    }
}
