//
//  PasswordResetView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 07.11.2024.
//

import SwiftUI

struct PasswordResetView: View {
    @State var email: String = ""
    @State var token: String = ""
    @State private var showEmailVerification: Bool = false
    @State private var sendError: String = ""
    @State private var showTextFieldError: Bool = false
    @State private var isFine: Bool = false
    @Environment(\.dismiss) var dismiss
    private var screenName: String = "Восстановление пароля"
    var body: some View {
        NavigationStack{
            VStack{
                HStack(spacing: 20){
                    StepView(number: "1", currentStep: 1, stepIndex: 1)
                    StepView(number: "2", currentStep: 1, stepIndex: 2)
                    StepView(number: "3", currentStep: 1, stepIndex: 3)
                }
                .padding()
                
                CustomText(
                    text: "Ввод данных аккаунта",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("fg")
                )
                .padding()
                
                VStack(alignment: .leading){
                    CustomText(
                        text: "Введите email аккаунта",
                        font: Font.custom("Inter", size: 14).weight(.semibold),
                        color: Color("fg")
                    )
                    CustomTextField(
                        input: $email, 
                        text: "example@example.com",
                        showTextFieldError: $showTextFieldError,
                        isFine: $isFine
                    )
                }
                .padding(.horizontal)
                HStack{
                    AuthActionButton(
                        action: send,
                        actionTitle: "Получить код"
                    )
                }
                .padding(.horizontal)
                CustomText(
                    text: "На указанную почту мы отправим письмо\nсо ссылкой для сброса пароля",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("sc2")
                )
                .frame(alignment: .center)
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
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .navigationTitle(screenName)
    }
    private func send() async{
        if !email.isEmpty{
            let parameters = [
                "email": email
            ]
            do{
                let response = try await abstractFetchData(
                    endpoint: "v1/auth/password",
                    parameters: parameters,
                    headers: [
                        "Content-Type": "application/json",
                        "accept" : "application/json"
                    ]
                )
                switch response["status_code"] as? Int{
                case 200:
                    showEmailVerification = true
                default:
                    print("s")
                    //showError(message: "oioioi")
                }
            }catch{
                //showError(message: "Упс... что-то пошло не так")
            }
            return
        }
    }
}
