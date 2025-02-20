//
//  SignInView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 14.02.2025.
//

import SwiftUI
import ComposableArchitecture
import Lottie

struct SignInView: View{
    let store: StoreOf<SignInFeature>
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack{
                VStack(alignment: .leading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 10, height: 20)
                    }
                    .customPadding(.bottom, 8)
                    CustomTextTCA(
                        font: AppFonts.header,
                        data: viewStore.currentHeaderContent.0,
                        color: Color.black
                    ).customPadding(.bottom, 8)
                    CustomTextTCA(
                        font: AppFonts.header2,
                        data: viewStore.currentHeaderContent.1,
                        color: Color.black
                    ).customPadding(.bottom, 40)
                    
                    /*
                     TEXTFIELD
                     */
                    CustomSignInField(text: viewStore.binding(
                        get: { $0.inputFieldData },
                        send: SignInFeature.Action.inputFieldDataChanged
                    ), title: "qwe", promt: viewStore.currentPromt, isPhoneAuth: viewStore.binding(get: {$0.isPhoneAuth}, send: SignInFeature.Action.isPhoneAuthBinding))
                    .customPadding(.bottom, 16)
                    
                    CustomButton(
                        text: CustomTextTCA(
                            font: AppFonts.button,
                            data: "Продолжить",
                            color: Color.white
                        ),
                        bgColor: Color.black
                    ){
                        viewStore.send(.continueButtonTapped)
                    }.customPadding(.bottom, 24)
                    
                    Spacer()
                    
                    CustomButton(
                        text: CustomTextTCA(
                            font: AppFonts.button,
                            data: "Войти другим способом",
                            color: Color.black
                        ),
                        bgColor: Color.white
                    ){
                        //viewStore.send(.)
                    }
                    CustomButton(
                        text: CustomTextTCA(
                            font: AppFonts.button,
                            data: viewStore.currentButtonContent,
                            color: Color.white
                        ),
                        bgColor: Color.black
                    ){
                        viewStore.send(.changeAuthMethodButtonTapped)
                    }.customPadding(.bottom, 24)
                }
            }
            .padding()
            .onAppear(){
                viewStore.send(.viewAppeared)
            }
            .hideBackButton()
        }
    }
}
