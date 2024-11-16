//
//  GoalsView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct goalsView: View{
    @Binding var goals: [Goal]
    @Binding var isLongPressing: Bool
    @Binding var selectedGoal: Goal?
    @Binding var isEditing: Bool
    @Binding var showAllGoalsView: Bool
    @Binding var currency: String
    @Binding var tokenData: TokenData
    
    var body: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    GoalsForEach(
                        goals: $goals,
                        isLongPressing: $isLongPressing,
                        isEditing: $isEditing,
                        selectedGoal: $selectedGoal
                    )
                    
                    if goals.count > 5 {
                        VStack {
                            Rectangle()
                                .cornerRadius(15)
                                .foregroundColor(Color("bg2"))
                                .frame(width: 200, height: 305)
                                .overlay(
                                    CustomText(
                                        text: "Показать все",
                                        font: Font.custom("Inter", size: 14).weight(.semibold),
                                        color: Color("fg")
                                    )
                                )
                                .onTapGesture {
                                    showAllGoalsView = true
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 280)
            }
            .sheet(isPresented: $showAllGoalsView) {
                AllGoalsView(
                    goals: $goals,
                    currency: $currency,
                    tokenData: $tokenData
                )
            }
            Spacer()
            CustomText(
                text: "Свайпните вниз, чтобы посмотреть ежемесячные платежи по целям",
                font: Font.custom("Gilroy", size: 15).weight(.semibold),
                color: Color("sc2")
            )
        }
    }
}

struct GoalsForEach:View{
    @Binding var goals: [Goal]
    @Binding var isLongPressing: Bool
    @Binding var isEditing: Bool
    @Binding var selectedGoal: Goal?
    
    var body: some View {
        ForEach(Array(goals.prefix(5))) { goal in
            GoalView(
                isLongPressing: $isLongPressing,
                isEditing: $isEditing,
                selectedGoal: $selectedGoal,
                goal: goal
            )
        }
    }
}

struct GoalView: View{
    let feedbackGeneratorHard = UIImpactFeedbackGenerator(style: .heavy)
    @Binding var isLongPressing: Bool
    @Binding var isEditing: Bool
    @Binding var selectedGoal: Goal?
    let goal: Goal
    var body: some View{
        let result = monthsPassedInts(from: goal.StartDate, to: goal.EndDate)
        let startDate = result.0
        let endDate = result.1
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                Image("education")
                    .resizable()
                    .frame(width: 25, height: 25)
                CustomText(
                    text: goal.GoalName,
                    font: Font.custom("Gilroy", size: 16).weight(.semibold),
                    color: Color("fg")
                )
                .frame(maxWidth: 155, maxHeight: 25, alignment: .leading)
            }
            HStack(spacing: 5) {
                CustomText(
                    text: "Цель:",
                    font: Font.custom("Gilroy", size: 12).weight(.semibold),
                    color: Color("sc2")
                )
                CustomText(
                    text: "\(goal.Need)",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("sc2")
                )
            }
            
            ZStack {
                Circle()
                    .stroke(
                        Color("m5").opacity(0.1),
                        lineWidth: 10
                    )
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(startDate) / CGFloat(endDate))
                    .stroke(
                        Color("m5"),
                        lineWidth: 10
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)
                
                CustomText(
                    text:  "\(Int(startDate))/\(Int(endDate))",
                    font: Font.custom("Inter", size: 36).weight(.semibold),
                    color: Color("fg")
                )
            }
            
            HStack(spacing: 5) {
                CustomText(
                    text: "Платёж:",
                    font: Font.custom("Gilroy", size: 12).weight(.semibold),
                    color: Color("sc2")
                )
                CustomText(
                    text: "{lastPayment}",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("m5")
                )
            }
            
        }
        .padding(10)
        .background(Color("bg1"))
        .cornerRadius(20)
        .frame(width: 200, height: 280)
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            isLongPressing = pressing
        }, perform: {
            selectedGoal = goal
            isEditing = true
            feedbackGeneratorHard.impactOccurred()
        })
    }
}
