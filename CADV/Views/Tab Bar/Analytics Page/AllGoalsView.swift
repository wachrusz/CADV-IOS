//
//  AllGoalsView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.10.2024.
//

import SwiftUI

struct AllGoalsView: View {
    @Binding var goals: Goals
    @State private var isLongPressing = false
    @State private var isEditing: Bool = false
    @State private var selectedGoal: Goal?
    let feedbackGeneratorHard = UIImpactFeedbackGenerator(style: .heavy)

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(goals: Binding<Goals>) {
            self._goals = goals
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        }
    
    private var pages: [[Goal]] {
        let goalsToShow = Array(goals.Array.dropFirst(2))
        return stride(from: 0, to: goalsToShow.count, by: 6).map {
            Array(goalsToShow[$0..<min($0 + 6, goalsToShow.count)])
        }
    }

    var body: some View {
            TabView {
                ForEach(pages.indices, id: \.self) { pageIndex in
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(pages[pageIndex], id: \.self) { goal in
                            VStack(spacing: 5) {
                                HStack(spacing: 5) {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 25, height: 25)
                                        .background(
                                            Image("edu")
                                        )
                                    Text(goal.GoalName)
                                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                        .lineSpacing(20)
                                        .foregroundColor(.black)
                                }.frame(maxHeight: 25)
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
                                        .trim(from: 0, to:  2 / CGFloat(goal.CurrentState))
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
                            .frame(width: 150, height: 200)
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
                        
                    }
                    .padding(.horizontal)
                }
        }
        .background(Color.white)
        .tabViewStyle(PageTabViewStyle())
        .sheet(isPresented: Binding<Bool>(
            get: { isEditing },
            set: { newValue in
                withAnimation {
                    isEditing = newValue
                }
            })) {
            if let goal = selectedGoal {
                EditGoalView(goal: goal, goals: $goals)
            } else {
                Text("Ошибка: цель не выбрана.")
            }
        }
    }
}
