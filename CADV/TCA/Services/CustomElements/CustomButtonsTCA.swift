//
//  CustomButtons.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.02.2025.
//

import SwiftUI

struct CustomButton: View {
    let text: CustomTextTCA
    let bgColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Rectangle()
            .overlay(text)
            .foregroundStyle(bgColor)
        }
        .frame(maxWidth: .infinity, maxHeight: 66)
        .background(bgColor)
        .cornerRadius(16)
    }
}

