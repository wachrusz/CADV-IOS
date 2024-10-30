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
    let feedbackGeneratorHard = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(Array(goals.prefix(2))) { goal in
                        VStack(spacing: 5) {
                            HStack(spacing: 5) {
                                Image("education")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                Text(goal.GoalName)
                                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                    .lineSpacing(20)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: 155, maxHeight: 25, alignment: .leading)
                            }
                            HStack(spacing: 5) {
                                Text("Цель:")
                                    .font(Font.custom("Gilroy", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                                Text("₽ \(goal.Need, specifier: "%.2f")")
                                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                            }
                            
                            ZStack {
                                Circle()
                                    .stroke(
                                        Color(red: 0.95, green: 0.91, blue: 0.95),
                                        lineWidth: 10
                                    )
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: 2 / CGFloat(goal.CurrentState))
                                    .stroke(
                                        Color(red: 0.53, green: 0.19, blue: 0.53),
                                        lineWidth: 10
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150)
                                
                                Text("2/\(goal.CurrentState)")
                                    .font(Font.custom("Inter", size: 36).weight(.semibold))
                                    .foregroundColor(.black)
                            }
                            
                            HStack(spacing: 5) {
                                Text("Платёж:")
                                    .font(Font.custom("Gilroy", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                                Text("₽ 5 000,00")
                                    .font(Font.custom("Inter", size: 12).weight(.semibold))
                                    .foregroundColor(Color(red: 0.53, green: 0.19, blue: 0.53))
                            }
                        }
                        .padding(10)
                        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                        .cornerRadius(20)
                        .frame(width: 200, height: 280)
                        .simultaneousGesture(TapGesture().onEnded {
                            print("Tapped on goal: \(goal.GoalName)")
                        })
                        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
                            isLongPressing = pressing
                        }, perform: {
                            selectedGoal = goal
                            isEditing = true
                            feedbackGeneratorHard.impactOccurred()
                        })
                    }
                    
                    VStack {
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(width: 200, height: 280)
                            .overlay(
                                Text("Показать все")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            )
                            .onTapGesture {
                                print("Переход на вьюшку с отображением всех целей")
                                showAllGoalsView = true
                            }
                    }
                }
                .padding(.horizontal)
                .frame(height: 280)
            }
            .sheet(isPresented: $showAllGoalsView) {
                AllGoalsView(goals: $goals)
            }
            Spacer()
            Text("Свайпните вниз, чтобы посмотреть ежемесячные платежи по целям")
                .padding()
                .foregroundColor(.black)
        }
    }
}
