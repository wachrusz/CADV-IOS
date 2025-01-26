//
//  AddGoalButton.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct addGoalButton: View{
    @Binding var goals: [Goal]
    
    var body: some View {
        NavigationLink(destination:
                        CreateGoalView(
                                goals: $goals
                        )) {
            VStack(spacing: 10) {
                Image("goalIcon")
                    .resizable()
                    .frame(width: 75, height: 75)
                
                CustomText(
                    text: "Создать новую цель",
                    font: Font.custom("Gilroy", size: 16).weight(.semibold),
                    color: Color("fg")
                )
                
                CustomText(
                    text: "Нажмите, чтобы продолжить",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("fg")
                )
            }
            .frame(maxWidth: 200, maxHeight: 305)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(20)
            .contentShape(Rectangle())
        }
    }
}
