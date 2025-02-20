//
//  CustomTexts.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.02.2025.
//

import SwiftUI

struct CustomTextTCA: View{
    let font: Font
    let data: String
    let color: Color
    
    var body: some View{
        Text(data).font(font).foregroundStyle(color)
    }
}

struct CustomSignInField: View{
    @Binding var text: String
    let title: String
    let promt: String
    @Binding var isPhoneAuth: Bool
    
    var body: some View{
        TextField(title, text: $text, prompt: Text(promt))
            .focusablePadding()
            .frame(height: 66)
            .background(.black.opacity(0.1))
            .cornerRadius(15)
            .keyboardType(isPhoneAuth ? .numberPad : .emailAddress)
            .accentColor(.black)
            .onChange(of: text) { newValue in
                if isPhoneAuth{
                    text = formatPhoneNumber(newValue)
                }
            }
    }

    private func formatPhoneNumber(_ input: String) -> String {
        let cleanedInput = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let maxDigits = 11
        let trimmedInput = String(cleanedInput.prefix(maxDigits))
        
        var digits = trimmedInput
        if digits.hasPrefix("7") {
            digits = String(digits.dropFirst())
        }
        
        var formattedNumber = "+7 "
        
        for (index, character) in digits.enumerated() {
            if index == 0{
                formattedNumber += "("
            }
            if index == 3 {
                formattedNumber += ") "
            } else if index == 6 || index == 8 {
                formattedNumber += "-"
            }
            formattedNumber.append(character)
        }
        
        return formattedNumber
    }
}
