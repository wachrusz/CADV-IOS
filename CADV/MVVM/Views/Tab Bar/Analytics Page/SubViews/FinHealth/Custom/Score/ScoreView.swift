//
//  ScoreView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct ScoreView: View {
    @Binding var score: Double
    let name: String
    let colorfg: Color
    let colorbg: Color
    
    var body: some View {
        HStack(alignment: .center){
            CustomText(
                text: name,
                font: .custom("Gilroy", size: 16).weight(.semibold),
                color: Color("fg")
            )
            .frame(alignment: .leading)
            Spacer()
            ScoreDiagramView(
                score: $score,
                colorfg: colorfg,
                colorbg: colorbg
            )
        }
    }
}
