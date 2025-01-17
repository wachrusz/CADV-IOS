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
    @Binding var urlElements: URLElements?
    
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
    private func resetPassword() async{
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
            
            do{
                let response = try await self.urlElements?.fetchData(
                    endpoint: "v1/auth/password",
                    method: "PUT",
                    parameters: parameters
                )
                switch response?["status_code"] as? Int{
                case 200:
                    self.isCompleted = true
                    
                    let additionalData: [String: Any] = [
                        "element": "password_reset"
                    ]
                    
                    FirebaseAnalyticsManager.shared.logUserActionEvent(
                        userId: getDeviceIdentifier(),
                        actionType: "completed",
                        screenName: "ChangePasswordView",
                        additionalData: additionalData
                    )
                case 400:
                    errorMessage = "Кажется, Вы что-то не так ввели"
                    showErrorPopup = true
                default:
                    errorMessage = "Упс... Что-то пошло не так..."
                    showErrorPopup = true
                }
            }
            catch let error{
                Logger.shared.log(.error, error)
            }
        }
    }
}
