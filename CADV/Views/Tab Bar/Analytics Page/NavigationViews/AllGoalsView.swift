//
//  AllGoalsView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.10.2024.
//

import SwiftUI

struct AllGoalsView: View {
    @Binding var goals: [Goal]
    @Binding var currency: String
    @Binding var urlElements: URLElements?
    
    @State private var isLongPressing = false
    @State private var isEditing: Bool = false
    @State private var selectedGoal: Goal?
    
    init(
        goals: Binding<[Goal]>,
        currency: Binding<String>,
        urlElements: Binding<URLElements?>
    ) {
        self._goals = goals
        self._currency = currency
        self._urlElements = urlElements
        
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }

    var body: some View {
        TabView {
            GoalForEachTabView(
                goals: $goals,
                isLongPressing: $isLongPressing,
                isEditing: $isEditing,
                selectedGoal: $selectedGoal
            )
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
                EditGoalView(
                    goal: goal,
                    goals: $goals,
                    currency: $currency,
                    urlElements: $urlElements
                )
            } else {
                Text("Ошибка: цель не выбрана.")
            }
        }
    }
}

struct GoalForEachTabView: View{
    let feedbackGeneratorHard = UIImpactFeedbackGenerator(style: .heavy)
    
    @Binding var goals: [Goal]
    @Binding var isLongPressing: Bool
    @Binding var isEditing: Bool
    @Binding var selectedGoal: Goal?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var pages: [[Goal]] {
        let goalsToShow = Array(goals.dropFirst(5))
        return stride(from: 0, to: goalsToShow.count, by: 6).map {
            Array(goalsToShow[$0..<min($0 + 6, goalsToShow.count)])
        }
    }
    
    var body: some View {
        LazyVStack {
            ForEach(pages, id: \.self) { page in
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(page, id: \.self) { goal in
                        GoalView(
                            isLongPressing: $isLongPressing,
                            isEditing: $isEditing,
                            selectedGoal: $selectedGoal,
                            goal: goal
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct GoalLazyView: View {
    @State private var isVisible = false
    
    @Binding var isLongPressing: Bool
    @Binding var isEditing: Bool
    @Binding var selectedGoal: Goal?
    
    let goal: Goal
    var body: some View {
        Group {
            if isVisible {
                GoalView(
                    isLongPressing: $isLongPressing,
                    isEditing: $isEditing,
                    selectedGoal: $selectedGoal,
                    goal: goal
                )
            } else {
                Color.clear
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    let isInScreen = geometry.frame(in: .global).intersects(UIScreen.main.bounds)
                    if isInScreen {
                        isVisible = true
                    }
                }
            }
        )
    }
}
