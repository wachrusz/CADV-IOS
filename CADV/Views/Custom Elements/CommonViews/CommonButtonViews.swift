//
//  Common.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI
//Auth only
struct AuthActionButton: View{
    var action: () async -> Void
    var actionTitle: String
    let font: Font = Font.custom("Gilroy", size: 16).weight(.semibold)
    
    var body: some View{
        Button(action: {
            Task{
                await action()
            }
        }) {
            CustomText(
                text: actionTitle,
                font: font,
                color: Color("fg")
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(.white)
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1))
    }
}


//ONLY IN NAVIGATED SCREENS
struct ActionDissmisButtons: View{
    @Environment(\.dismiss) var dismiss
    var action: () async -> Void
    var actionTitle: String
    let font: Font = Font.custom("Inter", size: 16).weight(.semibold)
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Button(action: {
                dismiss()
            }) {
                CustomText(
                    text: "Назад",
                    font: font,
                    color: Color("fg")
                )
            }
            .padding()
            .frame(maxHeight: 40)
            .background(.white)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 1))

            Button(action: {
                Task{
                    await action()
                }
            }) {
                CustomText(
                    text: actionTitle,
                    font: font,
                    color: .white
                )
            }
            .padding()
            .frame(height: 40)
            .background(Color.black)
            .cornerRadius(15)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

//MAIN, ANALYTICS, CATEGORY SETTINGS ETC.
struct CategorySwitchButtons: View{
    @Binding var selectedCategory: String
    @Binding var pageIndex: Int
    var categories: [String]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    CategorySwitchButton(
                        text: category,
                        isSelected: selectedCategory == category
                    )
                    .onTapGesture {
                        selectedCategory = category
                        pageIndex = 0
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategorySwitchButton: View{
    let text: String
    var isSelected: Bool
    var font: Font = Font.custom("Gilroy", size: 14).weight(.semibold)
    
    var body: some View {
        CustomText(
            text: text,
            font: font,
            color: isSelected ? Color("bg") : Color("fg")
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(isSelected ? .black : .gray.opacity(0.2))
        .cornerRadius(15)
    }
}

//MAIN, ANALYTICS
struct PlanSwitcherButtons: View{
    @Binding var selectedPlan: String
    @Binding var pageIndex: Int
    var plans: [String]
    
    var body: some View{
            HStack(spacing: 10) {
                ForEach(plans, id: \.self) { plan in
                    PlanSwitcherButton(
                        text: plan,
                        isSelected: selectedPlan == plan
                    )
                    .onTapGesture {
                        selectedPlan = plan
                    }
                }
            }
            .frame(height: 35)
            .padding(.horizontal)
    }
}

struct PlanSwitcherButton: View{
    let text: String
    var isSelected: Bool
    let font: Font = Font.custom("Gilroy", size: 14).weight(.semibold)
    var body: some View{
        CustomText(
            text: text,
            font: font,
            color: Color("fg")
        )
        .padding()
        .overlay(isSelected ? RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 2) : nil)
        .frame(idealWidth: 65)
        .cornerRadius(15)
    }
}

//IDK HOW TO NAME
struct ActionButtons<FirstContent: View, SecondContent: View>: View {
    @Binding var isFirstAction: Bool
    @Binding var isSecondAction: Bool
    var firstButtonContent: FirstContent
    var secondButtonContent: SecondContent
    let firstButtonText: String
    let secondButtonText: String
    let firstButtonAction: () -> Void
    let secondButtonAction: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            NavigationLink(
                destination: firstButtonContent,
                isActive: $isFirstAction
            ) {
                ActionButton(
                    text: firstButtonText,
                    textColor: .white,
                    backgroundColor: .black,
                    action: {
                        firstButtonAction()
                        isFirstAction = true
                    }
                )
            }
            
            NavigationLink(
                destination: secondButtonContent,
                isActive: $isSecondAction
            ) {
                ActionButton(
                    text: secondButtonText,
                    textColor: .black,
                    backgroundColor: Color("bg2"),
                    action: {
                        secondButtonAction()
                        isSecondAction = true
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

struct ActionButton: View{
    let text: String
    let textColor: Color
    let backgroundColor: Color
    let font: Font = Font.custom("Inter", size: 14).weight(.semibold)
    let action: () -> Void
    var body: some View{
        Button(action: action){
            CustomText(
                text: text,
                font: font,
                color: textColor
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(backgroundColor)
            .cornerRadius(15)
        }
    }
}
