//
//  ConfirmEmailContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 16.09.2024.
//

import SwiftUI
import UIKit

class CustomCodeTextField: UITextField {
    var onDeleteBackward: (() -> Void)?
    
    override func deleteBackward() {
        onDeleteBackward?() // Вызываем действие при нажатии Backspace
        super.deleteBackward()
    }
}

struct CustomCodeTextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    var onDeleteBackward: () -> Void
    var isFirstResponder: Bool = false
    
    func makeUIView(context: Context) -> CustomCodeTextField {
        let textField = CustomCodeTextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        textField.keyboardType = .numberPad
        
        textField.textColor = .black
        
        textField.onDeleteBackward = onDeleteBackward
        return textField
    }

    
    func updateUIView(_ uiView: CustomCodeTextField, context: Context) {
        uiView.text = text
        
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomCodeTextFieldWrapper
        
        init(_ parent: CustomCodeTextFieldWrapper) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textFieldText = textField.text as NSString? else { return false }
            let newText = textFieldText.replacingCharacters(in: range, with: string)
            if newText.count <= 1 {
                parent.text = newText
                return true
            }
            return false
        }
    }
}

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
                            CustomCodeTextFieldWrapper(
                                text: Binding(
                                    get: { code[index] },
                                    set: { newValue in
                                        if newValue.count == 1 {
                                            code[index] = newValue
                                            focusedField = index + 1 < 4 ? index + 1 : nil
                                        }
                                        if index == 3 && newValue.count == 1 {
                                            focusedField = 0
                                            validateCode()
                                        }
                                    }
                                ),
                                onDeleteBackward: {
                                    if code[index].isEmpty && index > 0 {
                                        focusedField = index - 1
                                    }
                                    code[index] = ""
                                },
                                isFirstResponder: focusedField == index
                            )
                            .frame(width: 50, height: 50)
                            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                            )
                            .focused($focusedField, equals: index)
                        }
                    }
                    .onAppear {
                        focusedField = nil
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
            focusedField = nil
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    private func validateCode() {
        let enteredCode = code.joined()
        print("CurrentCode is \(enteredCode)")
        if enteredCode == correctCode {
            isNavigationActive = true
        } else {
            code = Array(repeating: "", count: 4)
            focusedField = 0
            showErrorView = true
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
