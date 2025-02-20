//
//  PercentBlock.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct TempoPercentBlockView: View{
    @Binding var previousMonthSum: Double
    @Binding var currentMonthSum: Double
    let color: Color
    var body: some View{
        HStack{
            Rectangle()
                .frame(width: 60, height: 20)
                .foregroundStyle(color)
                .cornerRadius(5)
                .overlay(
                    CustomText(
                        text: formattedPercent(prev: previousMonthSum, curr: currentMonthSum),
                        font: .custom("Inter", size: 14).weight(.semibold),
                        color: Color("fg")
                    ),
                    alignment: .center
            )
        }
    }
    
    private func formattedPercent(prev: Double, curr: Double) -> String{
        return "\(prev>curr ? "-" : "+")\(prev/curr*100)%"
    }
}
