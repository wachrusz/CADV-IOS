//
//  OnboardingView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.02.2025.
//

import SwiftUI
import ComposableArchitecture
import Lottie

struct OnboardingView: View{
    let store: StoreOf<OnboardingFeature>
    
    var body: some View{
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack{
                VStack(alignment: .leading){
                    HStack{
                        ForEach(0..<viewStore.slidesCount){ index in
                            SliderIndicator(isActive: index == viewStore.currentSlide)
                        }
                    }
                    HStack{
                        Circle().frame(width: 24, height: 24)
                        CustomTextTCA(
                            font: AppFonts.header3,
                            data: "Наслаждайся cashadvisor",
                            color: Color.black
                        )
                    }
                    .customPadding(.bottom, 24)
                    
                    CustomTextTCA(
                        font: AppFonts.header,
                        data: viewStore.currentSlideContent.0,
                        color: Color.black
                    ).customPadding(.bottom, 8)
                    CustomTextTCA(
                        font: AppFonts.header2,
                        data: viewStore.currentSlideContent.1,
                        color: Color.black
                    ).customPadding(.bottom, 40)
                    
                    Rectangle()
                        .cornerRadius(17)
                        .foregroundStyle(Color.gray)
                        .frame(maxHeight: 361)
                    
                    Spacer()
                    
                    HStack{
                        CustomButton(
                            text: CustomTextTCA(
                                font: AppFonts.button,
                                data: "Sign Up",
                                color: Color.black
                            ),
                            bgColor: Color.gray
                        ){
                            viewStore.send(.signUpButtonTapped)
                        }
                        CustomButton(
                            text: CustomTextTCA(
                                font: AppFonts.button,
                                data: "Sign In",
                                color: Color.white
                            ),
                            bgColor: Color.black
                        ){
                            viewStore.send(.signInButtonTapped)
                        }
                    }
                }
                .customPadding(.horizontal, 16)
                .customPadding(.bottom, 16)
                .onAppear {
                    viewStore.send(.startTimer)
                }
                
                NavigationLink(
                    destination: SignInView(
                        store:
                            store.scope(
                            state: \.signInState,
                            action: \.signInAction
                        )
                    ), // Login
                    isActive: viewStore.binding(
                        get: { $0.isSignInNavigationActive },
                        send: OnboardingFeature.Action.signInButtonTapped
                    ),
                    label: {
                        Text("")
                    }
                )
                NavigationLink(
                    destination: EmptyView(), // register
                    isActive: viewStore.binding(
                        get: { $0.isSignUpNavigationActive },
                        send: OnboardingFeature.Action.signUpButtonTapped
                    ),
                    label: {
                        Text("")
                    }
                )
            }
        }
    }
}
