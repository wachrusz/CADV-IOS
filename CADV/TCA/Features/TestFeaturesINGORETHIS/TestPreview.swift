//
//  TestPreview.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.02.2025.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack {
            VStack {
                Spacer()
                
                HStack {
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(15)
                        .overlay(
                            Text("Финансовая грамотность")
                                .foregroundColor(.black)
                                .padding()
                        )
                        .frame(height: 50)
                    
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(15)
                        .overlay(
                            Text("2025")
                                .foregroundColor(.black)
                                .padding()
                        )
                        .frame(height: 50)
                }
                
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(15)
                    .overlay(
                        Text("Сравнение\nброкеров")
                            .frame(alignment: .leading)
                            .foregroundStyle(.black)
                            .padding()
                    ).frame(height: 150)
            }
        }
        .background(Color.black)
    }
}

