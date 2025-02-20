//
//  StepView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.11.2024.
//

import SwiftUI

struct StepView: View {
    let number: String
    let currentStep: Int
    let stepIndex: Int
    let font: Font = Font.custom("Inter", size: 12).weight(.semibold)
    
    var body: some View {
        CustomText(
            text: number,
            font: font,
            color: stepIndex < currentStep ? Color("sm1") : (stepIndex == currentStep ? Color("fg") : Color("sc2"))
        )
        .frame(width: 35, height: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(stepIndex < currentStep ? Color("sm1") : (stepIndex == currentStep ? Color("fg") : Color("sc2")), lineWidth: 1)
        )
    }
}
