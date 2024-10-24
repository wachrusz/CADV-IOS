//
//  EditGoalView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 09.10.2024.
//

import SwiftUI

struct EditGoalView: View {
    @State private var goalName: String
    @State private var goalAmount: String
    @State private var goalTime: String
    @Binding var goals: Goals
    var goal: Goal

    @Environment(\.presentationMode) var presentationMode
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""

    init(goal: Goal, goals: Binding<Goals>) {
        self.goal = goal
        self._goalName = State(initialValue: goal.GoalName)
        self._goalAmount = State(initialValue: String(goal.Need))
        self._goalTime = State(initialValue: String(goal.CurrentState))
        self._goals = goals
        print(".sheet, goal: \(goal)")
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    Text("Редактировать цель")
                        .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                        .lineSpacing(20)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Название цели:")
                            .font(Font.custom("Inter", size: 12).weight(.semibold))
                            .lineSpacing(15)
                            .foregroundColor(.black)
                        
                        TextField("", text: $goalName)
                            .placeholder(when: goalName.isEmpty) {
                                Text("Нажмите, чтобы ввести")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                            }
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(10)
                            .frame(width: 300, height: 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Размер цели в основной валюте:")
                            .font(Font.custom("Inter", size: 12).weight(.semibold))
                            .lineSpacing(15)
                            .foregroundColor(.black)
                        
                        HStack(alignment: .top, spacing: 10) {
                            Text("₽")
                                .font(Font.custom("Inter", size: 14).weight(.semibold))
                                .foregroundColor(.black)
                                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                .cornerRadius(10)
                            
                            TextField("", text: $goalAmount)
                                .placeholder(when: goalAmount.isEmpty) {
                                    Text("00.00")
                                        .foregroundColor(.black)
                                        .font(Font.custom("Inter", size: 14).weight(.semibold))
                                }
                                .font(Font.custom("Inter", size: 14).weight(.semibold))
                                .foregroundColor(.black)
                                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                .cornerRadius(10)
                                .keyboardType(.decimalPad)
                                .frame(width: 240, height: 40)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Планируемое время достижения в месяцах:")
                            .font(Font.custom("Inter", size: 12).weight(.semibold))
                            .lineSpacing(15)
                            .foregroundColor(.black)
                        
                        TextField("", text: $goalTime)
                            .placeholder(when: goalTime.isEmpty) {
                                Text("0")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Inter", size: 14).weight(.semibold))
                            }
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(10)
                            .frame(width: 300, height: 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .keyboardType(.numberPad)
                    }

                    HStack(alignment: .top, spacing: 20) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Назад")
                                .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                .lineSpacing(20)
                                .foregroundColor(.black)
                        }
                        .padding(EdgeInsets(top: 11, leading: 15, bottom: 9, trailing: 15))
                        .frame(height: 40)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1))

                        Button(action: {
                            validateAndUpdateGoal()
                        }) {
                            Text("Сохранить изменения")
                                .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                .lineSpacing(20)
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .frame(height: 40)
                        .background(Color(red: 0.53, green: 0.19, blue: 0.53))
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .offset(y: 20) 
            }.onAppear(){
                print("EditGoalView appeared")
                print("goalName: \(goalName), goalAmount: \(goalAmount), goalTime: \(goalTime)")
            }

            if showErrorPopup {
                VStack {
                    Text(errorMessage)
                        .font(Font.custom("Inter", size: 14).weight(.semibold))
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 2))
                        .scaleEffect(1.1)
                        .transition(.scale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6))
                    Spacer()
                }
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation {
                            showErrorPopup = false
                        }
                    }
                }
            }
        }
        .padding(.leading)
        .background(.white)
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }

    private func validateAndUpdateGoal() {
        if goalName.isEmpty {
            showError(message: "Название не должно быть пустым")
            return
        }
        
        guard let amount = Double(goalAmount), amount > 0 else {
            showError(message: "Сумма должна быть больше 0")
            return
        }
        
        guard let time = Int(goalTime), time >= 1 else {
            showError(message: "Время должно быть не меньше 1 месяца")
            return
        }

        // Обновляем существующую цель
        if let index = goals.Array.firstIndex(where: { $0.ID == goal.ID }) {
            goals.Array[index] = Goal(CurrentState: time, GoalName: goalName, ID: goal.ID, Need: amount, UserID: goal.UserID)
        }

        presentationMode.wrappedValue.dismiss()
    }

    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            showErrorPopup = true
        }
    }
}

