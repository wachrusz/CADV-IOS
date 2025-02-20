//
//  FinHealth.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct FinHealthView: View{
    @State var score: Double = 56.32
    @State var name: String = "1. Expences"
    @State var previousMonthSum: Double = 1000
    @State var currentMonthSum: Double = 500
    
    var body: some View{
        List{
            ExpenceDetailsView(
                score: $score,
                previousMonthSum: $previousMonthSum,
                currentMonthSum: $currentMonthSum
            )
        }
    }
}
