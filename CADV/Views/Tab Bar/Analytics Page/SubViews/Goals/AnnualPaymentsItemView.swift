//
//  AnnualPaymentsItem.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct annualPaymentsItem: View{
    var title: String
    var totalAmount: Double
    var color: Color
    var paidAmount: Double
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Image("education")
                .resizable()
                .frame(maxWidth: 40, maxHeight: 40)
            
            HStack {
                Text(title)
                    .font(.custom("Gilroy", size: 16).weight(.semibold))
                    .foregroundColor(.black)
                
                VStack {
                    Text("₽ \(formattedTotalAmount(amount: totalAmount))")
                        .font(.custom("Inter", size: 16).weight(.semibold))
                        .foregroundColor(color)
                    
                    GeometryReader { geometry in
                        let progress = min(max(paidAmount / totalAmount, 0), 1)
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * CGFloat(progress), height: 5)
                            .cornerRadius(2.5)
                    }
                    .frame(height: 5)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(2.5)
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}
