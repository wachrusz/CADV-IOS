//
//  StartViewTCA.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.02.2025.
//

import ComposableArchitecture
import SwiftUI

struct StartViewTCA: View {
    let store: StoreOf<StartViewFeature>

    
    //Shit Code
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                // Hashtags
                VStack(alignment: .leading) {
                    //too complex
                    ForEach(viewStore.hashTags, id: \.self) { tag in
                        CustomText(
                            text: tag,
                            font: Font.custom("Montserrat", size: 40).weight(.bold),
                            color: Color(tag == "#Cash Advisor" ? "fg" : "bg1")
                        )
                        .offset(x: viewStore.isVisible ? 0 : (tag == "#Cash Advisor" ? -1500 : 250), y: 0)
                        .opacity(viewStore.isVisible ? 1 : 0)
                        .animation(
                            .easeOut(duration: tag == "#Cash Advisor" ? 2 : 1)
                                .delay(Double(viewStore.hashTags.firstIndex(of: tag) ?? 0) * 0.1),
                            value: viewStore.isVisible
                        )
                    }
                }

                // Buttons Panel
                VStack(alignment: .center, spacing: 10) {
                    HStack(spacing: 20) {
                        NavigationLink(destination: RegisterView()) {
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
                        .onTapGesture {
                            viewStore.send(.logAnalyticsEvent("tapped", ["element": "register_button"]))
                        }

                        NavigationLink(destination: LoginView()) {
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
                        .onTapGesture {
                            viewStore.send(.logAnalyticsEvent("tapped", ["element": "login_button"]))
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
                .offset(x: 0, y: viewStore.startMovement ? 0 : 1500)
                .animation(.easeOut(duration: 2).delay(0.6), value: viewStore.startMovement)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onTapGesture {
                viewStore.send(.logAnalyticsEvent("tapped", ["element": "background"]))
            }
        }
    }
}
