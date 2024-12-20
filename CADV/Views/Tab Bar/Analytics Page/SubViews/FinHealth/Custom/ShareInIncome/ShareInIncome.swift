//
//  ShareInIncome.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct ShareInIncomeView: View{
    let name: String
    let colorfg: Color
    let colorbg: Color
    @Binding var previousMonthsum: Double
    @Binding var currentMonthsum: Double
    
    var body: some View{
        CustomText(
            text: name,
            font: .custom("Gilroy", size: 16).weight(.semibold),
            color: Color("fg")
        )
        .frame(alignment: .leading)
        HStack{
            ShareDiagramView(
                previousMonthsum: $previousMonthsum,
                currentMonthsum: $currentMonthsum,
                colorfg: colorfg,
                colorbg: colorbg
            )
            VStack{
                
            }
        }
    }
}

struct ShareDiagramView:View{
    @Binding var previousMonthsum: Double
    @Binding var currentMonthsum: Double
    let colorfg: Color
    let colorbg: Color
    var body:some View{
        let trim = currentMonthsum / previousMonthsum
        ZStack{
            Circle()
                .trim(from: 0, to: trim)
                .foregroundStyle(colorfg)
                .zIndex(1)
            
            Circle()
                .foregroundStyle(colorbg)
        }
    }
}

struct ShareBlockElementView: View{
    @Binding var text: String
    
    let color: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 20){
            Rectangle()
                .frame(width: 5, height: 60)
                .foregroundStyle(color)
        }
    }
}
