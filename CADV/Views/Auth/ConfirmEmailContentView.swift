//
//  ConfirmEmailContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 16.09.2024.
//

import SwiftUI

struct EnterVerificationEmailCode: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var code: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedField: Int?
    @State private var showErrorView = false
    @State private var isNavigationActive = false
    private let correctCode = "0000"
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack(spacing: 10) {
                    Text("Авторизация")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 20) {
                        StepView(number: "1", currentStep: 2, stepIndex: 1)
                        StepView(number: "2", currentStep: 2, stepIndex: 2)
                    }
                    
                    Text("Подтверждение")
                        .font(Font.custom("Inter", size: 12).weight(.semibold))
                        .foregroundColor(.black)
                }
                Spacer().frame(minHeight: 10, idealHeight: 30, maxHeight: 30).fixedSize()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Введите код из письма")
                        .font(Font.custom("Inter", size: 16).weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    HStack(spacing: 10) {
                        ForEach(0..<4, id: \.self) { index in
                            TextField("", text: Binding(
                                get: { code[index] },
                                set: { newValue in
                                    // Handle input
                                    if newValue.count <= 1 {
                                        code[index] = newValue
                                        // Move to next field
                                        if !newValue.isEmpty {
                                            focusedField = index + 1 < 4 ? index + 1 : nil
                                        }
                                    }
                                    // Handle deletion
                                    else if newValue.isEmpty {
                                        code[index] = newValue
                                        // Move to previous field
                                        focusedField = index > 0 ? index - 1 : nil
                                    }
                                    // Validate code when all fields are filled
                                    if index == 3 && newValue.count == 1 {
                                        validateCode()
                                    }
                                }
                            ))
                            .font(Font.custom("Inter", size: 18).weight(.semibold))
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                            )
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: index)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer().frame(minHeight: 10, idealHeight: 40, maxHeight: 40).fixedSize()
                
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        
                        Text("Выслать ещё раз")
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Не приходит код")
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(Color(red: 0.17, green: 0.21, blue: 0.61))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                Spacer(minLength: -keyboardHeight)
            }
            
            if showErrorView {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showErrorView = false
                        }
                    }
                VStack {
                        ErrorWrongCode()
                        .transition(.opacity)
                        .zIndex(1)
                }
                .onAppear {
                    UIApplication.shared.endEditing()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
            focusedField = 0
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    private func validateCode() {
        let enteredCode = code.joined()
        if enteredCode == correctCode {
            isNavigationActive = true
        } else {
            code = Array(repeating: "", count: 4) // Clear the code
            focusedField = 0 // Reset focus
            showErrorView = true // Show the error view
        }
    }
}

extension UIApplication {
    func endEditing() {
        windows.first?.endEditing(true)
    }
}

struct NewView: View {
    var body: some View {
        Text("Код верный, переход к новому экрану.")
    }
}
