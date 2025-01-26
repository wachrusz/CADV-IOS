//
//  ExpenceScore.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct ExpenceDetailsView: View {
    @Binding var score: Double
    @Binding var previousMonthSum: Double
    @Binding var currentMonthSum: Double
    let colorfg: Color = Color("m7")
    let colorbg: Color = Color("sm2")
    
    var body: some View {
        VStack(spacing: 20){
            ScoreView(
                score: $score,
                name: "1. Расходы",
                colorfg: colorfg,
                colorbg: colorbg
            )
            TempoView(
                previousMonthSum: $previousMonthSum,
                currentMonthSum: $currentMonthSum,
                color: colorbg,
                name: "1.1. Темп роста расходов"
            )
        }
    }
}
