//
//  GrowthTempoView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct TempoView: View {
    @Binding var previousMonthSum: Double
    @Binding var currentMonthSum: Double
    let color: Color
    let name: String
    
    var body: some View {
        VStack(alignment: .leading){
            CustomText(
                text: name,
                font: .custom("Gilroy", size: 16).weight(.semibold),
                color: Color("fg")
            )
            .frame(alignment: .leading)
            
            HStack(alignment: .center){
                TempoPointerView(
                    previousMonthSum: $previousMonthSum,
                    currentMonthSum: $currentMonthSum
                )
                Spacer()
                TempoPercentBlockView(
                    previousMonthSum: $previousMonthSum,
                    currentMonthSum: $currentMonthSum,
                    color: color
                )
            }
        }
    }
}
