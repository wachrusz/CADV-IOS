//
//  RegisterContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.09.2024.
//

import SwiftUI

struct RegisterContentView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var textEmail: String = ""
    @State private var isEmailValid: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack(spacing: 5) {
                        Text("Регистрация")
                            .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 20) {
                            StepView(number: "1", currentStep: 1, stepIndex: 1)
                            StepView(number: "2", currentStep: 1, stepIndex: 2)
                        }
                        
                        Text("Ввод данных аккаунта")
                            .font(Font.custom("Inter", size: 12).weight(.semibold))
                            .foregroundColor(.black)
                    }
                    .padding()

                    VStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Введите свой email")
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                                    .foregroundColor(.black)
                                
                                TextField("example@gmail.com", text: $textEmail, onEditingChanged: { isChanged in
                                    if !isChanged {
                                        if textFieldValidatorEmail(self.textEmail) {
                                            self.isEmailValid = true
                                        } else {
                                            self.isEmailValid = false
                                            self.textEmail = ""
                                        }
                                    }
                                })
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                    .cornerRadius(10)
                            }
                            .padding()

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Придумайте пароль")
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                                    .foregroundColor(.black)

                                SecureField("*********", text: .constant(""))
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                    .cornerRadius(10)
                            }
                            .padding()

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Подтвердите пароль")
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                                    .foregroundColor(.black)

                                SecureField("*********", text: .constant(""))
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                    .cornerRadius(10)

                                Text("Используйте цифры, буквы A-z и знак «_»")
                                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                            }
                            .padding()
                        }

                        HStack {
                            Spacer()
                            NavigationLink(destination: EnterVerificationEmailCode()) {
                                Text("Создать аккаунт")
                                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 140, height: 40)
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                            .padding()
                            Spacer()
                        }
                        Spacer(minLength: -keyboardHeight)
                    }
                    .animation(.easeOut(duration: 0.3))
                }
                .animation(.easeOut(duration: 0.3))
            }
        }
        .hideBackButton()
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}
