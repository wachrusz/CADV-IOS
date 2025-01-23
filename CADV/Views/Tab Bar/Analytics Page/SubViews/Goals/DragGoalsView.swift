//
//  DragGoalsView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct DragGoalsView: View{
    @Binding var goals: [Goal]
    @Binding var annualPayments: [AnnualPayment]
    @Binding var isLongPressing: Bool
    @Binding var selectedGoal: Goal?
    @Binding var isEditing: Bool
    @Binding var showAllGoalsView: Bool
    @Binding var showAnnualPayments: Bool
    @Binding var dragOffset: CGSize
    let feedbackGeneratorMedium = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            goalsSectionView(
                goals: $goals,
                isLongPressing: $isLongPressing,
                selectedGoal: $selectedGoal,
                isEditing: $isEditing,
                showAllGoalsView: $showAllGoalsView
            )
            .offset(y: showAnnualPayments ? UIScreen.main.bounds.height + dragOffset.height : dragOffset.height)
            .opacity(showAnnualPayments ? 0 : 1)
            .zIndex(showAnnualPayments ? 0 : 1)
            .animation(.easeInOut, value: dragOffset.height)
            
            annualPaymentsSection(
                annualPayments: $annualPayments
            )
            .offset(y: showAnnualPayments ? dragOffset.height : UIScreen.main.bounds.height + dragOffset.height)
            .opacity(showAnnualPayments ? 1 : 0)
            .zIndex(showAnnualPayments ? 1 : 0)
            .animation(.easeInOut, value: dragOffset.height)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = value.translation.height
                    dragOffset.height = min(max(newOffset, -50), 50)
                }
                .onEnded { value in
                    withAnimation {
                        if value.translation.height < -100 {
                            feedbackGeneratorMedium.impactOccurred()
                            showAnnualPayments = true
                        } else if value.translation.height > 100 {
                            feedbackGeneratorMedium.impactOccurred()
                            showAnnualPayments = false
                        }
                        dragOffset = .zero
                    }
                }
        )
        .edgesIgnoringSafeArea(.all)
    }
}
