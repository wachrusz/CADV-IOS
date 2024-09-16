//
//  LoginContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.09.2024.
//
import SwiftUI

struct LoginContentView: View {
    @State private var keyboardHeight: CGFloat = 0
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    VStack(spacing: 5) {
                        Text("Авторизация")
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
                    Spacer().frame(minHeight: 10, idealHeight: 30, maxHeight: 40).fixedSize()
                    
                    VStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Введите email")
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                                    .lineSpacing(15)
                                    .foregroundColor(.black)
                                TextField("example@gmail.com", text: .constant(""))
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Введите пароль")
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                                    .lineSpacing(15)
                                    .foregroundColor(.black)
                                SecureField("*********", text: .constant(""))
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                            HStack(alignment: .top, spacing: 20) {
                                Spacer()
                                NavigationLink(destination: EnterVerificationEmailCode()) {
                                    Text("Войти")
                                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                        .lineSpacing(20)
                                        .foregroundColor(.white)
                                        .frame(width: 140, height: 40)
                                        .background(Color.black)
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Забыли пароль
                                }) {
                                    Text("Забыли пароль?")
                                        .font(Font.custom("Inter", size: 14).weight(.semibold))
                                        .foregroundColor(Color(red: 0.17, green: 0.21, blue: 0.61))
                                }
                                .frame(width: 140, height: 40)
                                Spacer()
                            }
                        }
                    }
                    Spacer(minLength: -keyboardHeight)
                }
                .animation(.easeOut(duration: 0.3))
            }
            .animation(.easeOut(duration: 0.3))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(false)
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

struct StepView: View {
    let number: String
    let currentStep: Int
    let stepIndex: Int
    
    var body: some View {
        Text(number)
            .font(Font.custom("Inter", size: 12).weight(.semibold))
            .foregroundColor(stepIndex < currentStep ? .black : (stepIndex == currentStep ? Color(red: 0.22, green: 0.49, blue: 0.21) : .gray))
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .frame(width: 35, height: 20)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(stepIndex == currentStep ? Color(red: 0.22, green: 0.49, blue: 0.21) : .gray, lineWidth: 0.75)
            )
    }
}
