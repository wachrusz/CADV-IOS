//
//  LoginContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.09.2024.
//
import Foundation
import SwiftUI

class URLSessionHelper: NSObject, URLSessionDelegate {
    static let shared = URLSessionHelper()

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct LoginView: View{
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showPasswordReset: Bool = false
    @State private var showEmailVerification: Bool = false
    @State private var loginError: String = ""
    @State private var token: String = ""
    @State private var showErrorPopup: Bool = false
    @State private var showTextFieldError: Bool = false
    @State private var showSecureFieldError: Bool = false
    @State private var isTextFieldFine: Bool = false
    @State private var isSecureFieldFine: Bool = false
    private var screenName: String = "Авторизация"
    @State private var navigationPath = NavigationPath()

    var body: some View{
        ZStack{
            NavigationStack(path: $navigationPath){
                VStack{
                    HStack(spacing: 20){
                        StepView(number: "1", currentStep: 1, stepIndex: 1)
                        StepView(number: "2", currentStep: 1, stepIndex: 2)
                    }
                    .padding(.top)
                    CustomText(
                        text: "Ввод данных аккаунта",
                        font: Font.custom("Inter", size: 12).weight(.semibold),
                        color: Color("fg")
                    )
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 10){
                        CustomText(
                            text: "Введите email",
                            font: Font.custom("Inter", size: 14).weight(.semibold),
                            color: Color("fg")
                        )
                        CustomTextField(
                            input: $email,
                            text: "example@example.com",
                            showTextFieldError: $showTextFieldError ,
                            isFine: $isTextFieldFine
                        )
                        .onChange(of: email) { newValue in
                            validateEmail(newValue)
                        }
                        CustomText(
                            text: "Введите пароль",
                            font: Font.custom("Inter", size: 14).weight(.semibold),
                            color: Color("fg")
                        )
                        CustomSecureField(
                            input: $password,
                            showSecureFieldError: $showSecureFieldError,
                            isFine: $isSecureFieldFine,
                            errorMessage: $loginError
                        )
                        .padding(.bottom)
                        
                        HStack{
                            AuthActionButton(
                                action: login,
                                actionTitle: "Войти"
                            )
                            .frame(alignment: .leading)
                            
                            CustomText(
                                text: "Забыли пароль?",
                                font: Font.custom("Inter", size: 14).weight(.semibold),
                                color: Color("sm3")
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .onTapGesture {
                                showPasswordReset.toggle()
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                    NavigationLink(
                        destination: EnterVerificationEmailCode(
                            email: $email,
                            token: $token,
                            isNew: false,
                            previousScreenName: screenName
                            ),
                        isActive: $showEmailVerification,
                        label: {EmptyView()}
                    )
                    NavigationLink(
                        destination: PasswordResetView(),
                        isActive: $showPasswordReset,
                        label: {EmptyView()}
                    )
                }
            }
            ErrorPopUp(
                showErrorPopup: $showErrorPopup,
                errorMessage: loginError
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .zIndex(1)
        }
        .navigationTitle(screenName)
        .colorScheme(.light)
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .tint(.black)
    }
    
    private func login() {
        if isTextFieldFine && isSecureFieldFine {
            let parameters = [
                "email": email,
                "password": password
            ]
            
            abstractFetchData(
                endpoint: "v1/auth/login",
                parameters: parameters,
                headers: ["Content-Type": "application/json", "accept" : "application/json"]
            ) { result in
                switch result {
                case .success(let responseObject):
                    print("Response body: \(responseObject)")
                    switch responseObject["status_code"] as? Int {
                    case 200:
                        token = responseObject["token"] as? String ?? ""
                        self.showEmailVerification = true
                    case 401:
                        self.loginError = "Кажется, Вы что-то не так ввели..."
                        self.showErrorPopup = true
                    default:
                        self.loginError = "Упс... Что-то пошло не так..."
                        self.showErrorPopup = true
                    }
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.loginError = "Упс... Что-то пошло не так..."
                    }
                }
            }
        }else{
            showErrorPopup = true
        }
    }
    private func validateEmail(_ email: String) {
        if !email.isEmpty{
            showTextFieldError = !isValidEmail(email)
            isTextFieldFine = isValidEmail(email)
        }else{
            showTextFieldError = false
            isTextFieldFine = false
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email){
            self.loginError = "Некорректный email"
            return false
        }
        self.loginError = ""
        return true
    }
}


