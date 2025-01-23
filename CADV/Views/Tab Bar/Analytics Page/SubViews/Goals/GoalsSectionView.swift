//
//  GoalsSectionView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct goalsSectionView: View{
    @Binding var goals: [Goal]
    @Binding var isLongPressing: Bool
    @Binding var selectedGoal: Goal?
    @Binding var isEditing: Bool
    @Binding var showAllGoalsView: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 10){
                if goals.isEmpty{
                    Text("Финансовые Цели")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .lineSpacing(15)
                        .foregroundColor(.black)
                }else{
                    Text("Финансовые Цели")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .lineSpacing(15)
                        .foregroundColor(.black)
                    
                    NavigationLink(
                        destination: CreateGoalView(
                                        goals: $goals
                                    )
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.black)
                    }
                    .padding(.trailing)
                }
            }
            
            HStack(spacing: 10) {
                Text("0/\(goals.count)")
                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                    .lineSpacing(15)
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            }
            .padding(.leading)
            
            switch goals.count {
            case 0:
                addGoalButton(
                    goals: $goals
                )
            default:
                goalsView(
                    goals: $goals,
                    isLongPressing: $isLongPressing,
                    selectedGoal: $selectedGoal,
                    isEditing: $isEditing,
                    showAllGoalsView: $showAllGoalsView
                )
            }
        }
    }
}
