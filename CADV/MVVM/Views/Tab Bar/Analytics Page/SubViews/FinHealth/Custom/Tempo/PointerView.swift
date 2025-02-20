//
//  PointerView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct TempoPointerView: View{
    @Binding var previousMonthSum: Double
    @Binding var currentMonthSum: Double
    var body: some View{
        HStack{
            CustomText(
                text: formattedTotalAmount(amount: previousMonthSum),
                font: .custom("Inter", size: 14).weight(.semibold),
                color: Color("fg")
            )
            
            Image(systemName: "arrow.forward")
            
            CustomText(
                text: formattedTotalAmount(amount: currentMonthSum),
                font: .custom("Inter", size: 14).weight(.semibold),
                color: Color("fg")
            )
        }
    }
}

