//
//  CustomText.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.11.2024.
//

import SwiftUI

struct CustomText: View{
    let text: String
    let font: Font
    let color: Color
    
    var body: some View{
        Text(text)
            .foregroundColor(color)
            .textScale(.default)
            .font(
                font
            )
    }
}

struct CustomTextField: View {
    @Binding var input: String
    let text: String
    @Binding var showTextFieldError: Bool
    @Binding var isFine: Bool
    let font: Font = Font.custom("Inter", size: 14).weight(.semibold)
    let color: Color = Color("fg")
    
    var body: some View{
        TextField(text, text: $input)
            .padding()
            .foregroundColor(color)
            .font(font)
            .background(Color("bg1"))
            .frame(maxWidth: .infinity)
            .cornerRadius(15)
            .overlay(showTextFieldError ? RoundedRectangle(cornerRadius: 15).stroke(Color("m7")) : nil)
            .overlay(isFine ? RoundedRectangle(cornerRadius: 15).stroke(Color("m6")) : nil)
            .animation(.easeInOut, value: isFine)
    }
}

struct CustomSecureField: View{
    @Binding var input: String
    @State private var isSecure: Bool = true
    @Binding var showSecureFieldError: Bool
    @Binding var isFine: Bool
    @Binding var errorMessage: String
    
    private let secureButton: String = "SecureButton"
    private let secureText: String = "********"
    let font: Font = Font.custom("Inter", size: 14).weight(.semibold)
    let color: Color = Color("fg")
    
    var body: some View{
        ZStack{
            if isSecure || input.isEmpty{
                SecureField(secureText, text: $input)
                    .padding()
                    .background(Color("bg1"))
                    .foregroundColor(color)
                    .font(font)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(15)
                    .overlay(showSecureFieldError ? RoundedRectangle(cornerRadius: 15).stroke(Color("m7")) : nil)
                    .overlay(isFine ? RoundedRectangle(cornerRadius: 15).stroke(Color("m6")) : nil)
                    .animation(.easeInOut, value: isFine)
            }
            else{
                CustomTextField(
                    input: $input,
                    text: "",
                    showTextFieldError: $showSecureFieldError,
                    isFine: $isFine
                )
            }
            Button(action: {
                isSecure = !isSecure
            }, label: {
                Image(secureButton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(10)
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
        }
        .onChange(of: input) { newValue in
            validatePassword(newValue)
        }
    }
    
    func validatePassword(_ password: String) {
        if !password.isEmpty{
            showSecureFieldError = !isPasswordValid(password)
            isFine = isPasswordValid(password)
        }else{
            showSecureFieldError = false
            isFine = false
        }
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "[A-Z0-9a-z_]{8,64}"
        if !NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password){
            self.errorMessage = "Пароль не соответствует шаблону"
            return false
        }
        self.errorMessage = ""
        return true
    }
}
