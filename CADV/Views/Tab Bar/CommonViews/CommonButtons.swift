//
//  Common.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI

//ONLY IN NAVIGATED SCREENS
struct ActionDissmisButtons: View{
    @Environment(\.presentationMode) var presentationMode
    var action: () -> Void
    var actionTitle: String
    let fontName: String
    let fontSize: CGFloat
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Назад")
                    .font(Font.custom(fontName, size: fontSize).weight(.semibold))//16gillroy
                    .lineSpacing(20)
                    .foregroundColor(.black)
            }
            .padding(EdgeInsets(top: 11, leading: 15, bottom: 9, trailing: 15))
            .frame(height: 40)
            .background(.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1))

            Button(action: {
                action()
            }) {
                Text(actionTitle)
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
}

//MAIN, ANALYTICS, CATEGORY SETTINGS ETC.
struct CategorySwitchButtons: View{
    @Binding var selectedCategory: String
    @Binding var pageIndex: Int
    let fontName: String
    let fontSize: CGFloat
    var categories: [String]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    CategorySwitchButton(text: category, isSelected: selectedCategory == category, fontName: fontName, fontSize: fontSize)//14inter
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
    let fontName: String
    let fontSize: CGFloat
    
    var body: some View {
        Text(text)
            .font(.custom(fontName, size: fontSize).weight(.semibold))
            .foregroundColor(isSelected ? .white : .black)
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
    let fontName: String
    let fontSize: CGFloat
    var plans: [String]
    
    var body: some View{
            HStack(spacing: 10) {
                ForEach(plans, id: \.self) { plan in
                    PlanSwitcherButton(text: plan, isSelected: selectedPlan == plan, fontName: fontName, fontSize: fontSize)
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
    let fontName: String
    let fontSize: CGFloat
    
    var body: some View{
        Text(text)
            .font(.custom(fontName, size: fontSize).weight(.semibold))
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .frame(idealWidth: 65)
            .background(isSelected ? Color.black : Color.white)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.black.opacity(0.1), lineWidth: 1))
    }
}

//IDK HOW TO NAME
struct ActionButtons<FirstContent: View, SecondContent: View>: View{
    @Binding var isFirstAction: Bool
    @Binding var isSecondAction: Bool
    var firstButtonContent: FirstContent
    var secondButtonContent: SecondContent
    let firstButtonText: String
    let secondButtonText: String
    let fontName: String
    let fontSize: CGFloat
    let firstButtonAction: () -> Void
    let secondButtonAction: () -> Void
    
    var body: some View{
        HStack(spacing: 20) {
            ActionButton(
                text: firstButtonText, textColor: .white, backgroundColor: .black, fontName: fontName, fontSize: fontSize,
                action: {
                    firstButtonAction()
                    isFirstAction = true
                }
            ).sheet(isPresented: $isFirstAction){
                firstButtonContent
            }
            
            ActionButton(
                text: secondButtonText, textColor: .black,backgroundColor: .gray.opacity(0.2), fontName: fontName, fontSize: fontSize,
                action: {
                    secondButtonAction()
                    isSecondAction = true
                }
            )
            .sheet(isPresented: $isSecondAction) {
                secondButtonContent
            }
        }
        .padding(.horizontal)
    }
}

struct ActionButton: View{
    let text: String
    let textColor: Color
    let backgroundColor: Color
    let fontName: String
    let fontSize: CGFloat
    let action: () -> Void
    var body: some View{
        Button(action: action){
            Text(text)
                .font(.custom(fontName, size: fontSize).weight(.semibold))
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }
}
