//
//  LoginView.swift
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
    @Binding var urlElements: URLElements?
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
    @State private var isLoading: Bool = false
    private var screenName: String = "Авторизация"
    @State private var navigationPath = NavigationPath()
    
    init(urlElements: Binding<URLElements?>){
        self._urlElements = urlElements
    }
    
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
                            .disabled(isLoading)
                            
                            CustomText(
                                text: "Забыли пароль?",
                                font: Font.custom("Inter", size: 14).weight(.semibold),
                                color: Color("sm3")
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .onTapGesture {
                                showPasswordReset.toggle()
                                
                                let additionalData: [String: Any] = [
                                    "element": "forgot_password_button"
                                ]
                                
                                FirebaseAnalyticsManager.shared.logUserActionEvent(
                                    userId: getDeviceIdentifier(),
                                    actionType: "tapped",
                                    screenName: "LoginView",
                                    additionalData: additionalData
                                )
                            }
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                    NavigationLink(
                        destination: EnterVerificationEmailCode(
                            email: $email,
                            token: $token,
                            isNew: false,
                            previousScreenName: screenName,
                            urlElements: $urlElements
                        ),
                        isActive: $showEmailVerification,
                        label: {EmptyView()}
                    )
                    NavigationLink(
                        destination: PasswordResetView(
                            urlElements: $urlElements
                        ),
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
    
    private func login() async{
        isLoading = true
        if isTextFieldFine && isSecureFieldFine {
            let parameters = [
                "email": email.lowercased(),
                "password": password
            ]
            do{
                let response = try await self.urlElements?.fetchData(
                    endpoint: "v1/auth/login",
                    parameters: parameters
                )
                switch response?["status_code"] as? Int{
                case 200:
                    token = response?["token"] as? String ?? ""
                    self.showEmailVerification = true
                    
                    let additionalData: [String: Any] = [
                        "element": "login"
                    ]
                    
                    FirebaseAnalyticsManager.shared.logUserActionEvent(
                        userId: getDeviceIdentifier(),
                        actionType: "started",
                        screenName: "LoginView",
                        additionalData: additionalData
                    )
                    
                case 401:
                    self.loginError = "Кажется, Вы что-то не так ввели..."
                    self.showErrorPopup = true
                    self.isLoading = false
                default:
                    self.loginError = "Упс... Что-то пошло не так..."
                    self.showErrorPopup = true
                    self.isLoading = false
                }
            }catch let error{
                Logger.shared.log(.error, error)
                self.loginError = "error"
                self.showErrorPopup = true
                self.isLoading = false
            }
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
