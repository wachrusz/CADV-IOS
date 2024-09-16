//
//  CustomTextField.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.09.2024.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let isError: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .frame(width: 300, height: 40)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isError ? Color(red: 0.92, green: 0.36, blue: 0.12) : Color(red: 0.11, green: 0.83, blue: 0.18), lineWidth: 0.5)
            )
            .font(.custom("Inter", size: 14).weight(.semibold))
            .foregroundColor(isError ? .red : .black)
    }
}

struct EmailField: View {
    @Binding var email: String
    var body: some View {
        CustomTextField(text: $email, placeholder: "example@gmail.com", isError: false)
    }
}

struct VerificationCodeField: View {
    @State private var code: [String] = Array(repeating: "", count: 4)

    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                TextField("_", text: $code[index])
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 50)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
            }
        }
        .frame(width: 300, height: 40)
    }
}

struct PasswordField: View {
    @Binding var password: String
    @State private var isSecure: Bool = true

    var body: some View {
        ZStack {
            if isSecure {
                SecureField("*********", text: $password).foregroundColor(password.isEmpty ?.gray : .black)
            } else {
                TextField("*********", text: $password).foregroundColor(password.isEmpty ? .gray : .black)
            }
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .frame(width: 24, height: 24)
            .offset(x: 130)
        }
        .padding()
        .frame(width: 300, height: 40)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .cornerRadius(10)
    }
}

struct ValueField: View {
    @Binding var amount: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    Text("₽")
                        .font(Font.custom("Inter", size: 14).weight(.semibold))
                        .foregroundColor(.black)
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .frame(width: 60, height: 40)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                .cornerRadius(10)
            }
            TextField("Сумма", text: $amount)
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .frame(width: 230, height: 40)
                .foregroundColor(.black)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                .cornerRadius(10)
        }
        .frame(width: 300, height: 40)
    }
}
