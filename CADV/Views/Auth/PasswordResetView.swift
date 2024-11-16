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
    private func send(){
        if !email.isEmpty{
            let parameters = [
                "email": email
            ]
            
            abstractFetchData(
                endpoint: "v1/auth/password",
                parameters: parameters,
                headers: ["Content-Type": "application/json", "accept" : "application/json"]
            ) { result in
                switch result {
                case .success(let responseObject):
                    switch responseObject["status_code"] as? Int {
                    case 200:
                        token = responseObject["token"] as? String ?? ""
                        self.showEmailVerification = true
                    case 401:
                        self.sendError = "Кажется, Вы что-то не так ввели..."
                        //self.showErrorPopup = true
                    default:
                        self.sendError = "Упс... Что-то пошло не так..."
                        //self.showErrorPopup = true
                    }
                    
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.sendError = "Request error: \(error.localizedDescription)"
                    }
                }
            }
        }
        return
    }
}
