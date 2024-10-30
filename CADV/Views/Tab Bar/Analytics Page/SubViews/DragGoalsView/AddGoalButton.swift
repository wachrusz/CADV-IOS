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
        NavigationLink(destination: CreateGoalView(goals: $goals)) {
            VStack(spacing: 10) {
                Image("goalIcon")
                    .resizable()
                    .frame(width: 75, height: 75)
                
                Text("Создать новую цель")
                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                    .foregroundColor(.black)
                
                Text("Нажмите, чтобы продолжить")
                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            }
            .frame(maxWidth: 200, maxHeight: 305)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(20)
            .contentShape(Rectangle())
        }
    }
}
