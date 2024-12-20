//
//  StartContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.09.2024.
//

import SwiftUI

struct Start: View {
    @Binding var urlElements: URLElements?
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                NavigationLink(destination: NewUser(urlElements: $urlElements)) {
                    VStack {
                        Spacer()

                        CustomText(
                            text: "Cash Advisor",
                            font: Font.custom("Montserrat", size: 40).weight(.bold),
                            color: Color("fg")
                        )
                        
                        CustomText(
                            text: "Управляйте личными финансами эффективно",
                            font: Font.custom("Inter", size: 14).weight(.semibold),
                            color: Color("sc2")
                        )

                        Spacer()

                        CustomText(
                            text: "Нажмите, чтобы продолжить",
                            font: Font.custom("Gilroy", size: 16).weight(.semibold),
                            color: Color("sc2")
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct NewUser: View {
    @State private var isVisible: Bool = false
    @State private var startMovement: Bool = false
    @Binding var urlElements: URLElements?
    let hashTags: [String] = [
        "#финздоровье",
        "#акции",
        "#дивиденды",
        "#финграм",
        "#благосостояние",
        "#обязательства",
        "#Cash Advisor",
        "#активы",
        "#инвестиции",
        "#налоги",
        "#банки",
        "#сбережения",
        "#планирование",
        "#бюджет",
        "#доходы"
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                ForEach(hashTags, id: \.self) { tag in
                    CustomText(
                        text: tag,
                        font: Font.custom("Montserrat", size: 40).weight(.bold),
                        color: Color(tag == "#Cash Advisor" ? "fg" : "bg1")
                    )
                    .offset(x: isVisible ? 0 : (tag == "#Cash Advisor" ? -1500 : 250), y: 0)
                    .opacity(isVisible ? 1 : 0)
                    .animation(
                        .easeOut(
                            duration: tag == "#Cash Advisor" ? 2 : 1
                        )
                        .delay(
                            Double(
                                hashTags.firstIndex(of: tag) ?? 0) * 0.1
                        ), value: isVisible
                    )
                    .onAppear {
                        if tag == "#Cash Advisor" {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 * Double(hashTags.count)) {
                                withAnimation {
                                    self.isVisible = true
                                }
                            }
                        } else {
                            withAnimation {
                                self.isVisible = true
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .center, spacing: 10) {
                HStack(spacing: 20) {
                    NavigationLink(destination: RegisterView(
                        urlElements: $urlElements
                    )){
                        CustomText(
                            text: "Регистрация",
                            font: Font.custom("Gilroy", size: 16).weight(.semibold),
                            color: .white
                        )
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding()
                    }
                    NavigationLink(destination: LoginView(urlElements: $urlElements)) {
                        CustomText(
                            text: "Вход",
                            font: Font.custom("Gilroy", size: 16).weight(.semibold),
                            color: Color("fg")
                        )
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color("bg"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding()
                    }
                }
                
                CustomText(
                    text: "Зарегистрируйтесь, если у Вас нет аккаунта, \nили войдите, если аккаунт уже создан",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("sc2")
                )
                .multilineTextAlignment(.center)
                .padding(.bottom)
            }
            .background(Color("bg"))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            .offset(x: 0, y: startMovement ? 0 : 1500)
            .animation(
                .easeOut(
                    duration: 2
                )
                .delay(0.6), value: startMovement
            )
            .onAppear {
                withAnimation {
                    self.startMovement.toggle()
                }
            }
        }
        //.navigationBarBackButtonHidden(true)
        .navigationTitle("")
    }
}

struct StartView: View {
    @Binding var urlElements: URLElements?
    var body: some View {
        Start(urlElements: $urlElements)
    }
}
