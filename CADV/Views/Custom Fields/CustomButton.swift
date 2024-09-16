//
//  File.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.09.2024.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter", size: 14).weight(.semibold))
                .foregroundColor(.white)
                .padding()
                .frame(width: 300, height: 40)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
