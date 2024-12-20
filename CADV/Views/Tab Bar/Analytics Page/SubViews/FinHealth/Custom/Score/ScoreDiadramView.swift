//
//  ScoreDiadramView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.12.2024.
//

import SwiftUI

struct ScoreDiagramView: View {
    @Binding var score: Double
    let colorfg: Color
    let colorbg: Color
    
    var body: some View {
        let maxWidth: CGFloat = 150
        let width = (score / 100) * maxWidth
        
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: maxWidth, height: 20)
                .foregroundColor(colorbg)
                .cornerRadius(15)
            
            Rectangle()
                .frame(width: width, height: 20)
                .foregroundColor(colorfg)
                .cornerRadius(15)
                .overlay(
                    CustomText(
                        text: "\(Int(score))",
                        font: .custom("Inter", size: 14).weight(.semibold),
                        color: Color.white
                    ).padding(),
                    alignment: .leading
                )
                .zIndex(1)
        }
    }
}
