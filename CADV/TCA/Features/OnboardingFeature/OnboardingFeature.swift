//
//  OnboardingFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.02.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct OnboardingFeature{
    @ObservableState
    struct State: Equatable{
        let slidesContent: [Int: (String, String)] =
        [
            0: ("Добро пожаловать  в CashAdvisor",
                "Твой личный друг и верный советник в мире финансов, помогаем быть осмысленными"),
            1: ("Инвестируйте капитал правильно",
                "Используйте наши аутентичные статьи связанные с финансовой грамотностью"),
            2: ("Умный анализ доходов и расходов",
                "С нашим приложением, вы сможете удобно анализировать капитал с помощью графиков"),
            3: ("Распознование счетов и скриншотов",
                "Анализировать с помощью камерты чеки, хранить их и документировать в сервисе"),
            4: ("Удобная кастомизация карту",
                "Кастомизируйте карту и другие атрибуты, чтобы удобно разбираться в счетах"),
        ]
        
        let slidesCount: Int = 5
        let slideDuration: Double = 5.0
        var currentSlide: Int = 0 // from zero to four [0,1,2,3,4]
        var currentSlideContent: (String,String) = ("","")
        
        var isSignInNavigationActive = false
        var isSignUpNavigationActive = false
        
        
        //This stupid shit required me to write this
        static func == (lhs: State, rhs: State) -> Bool {
            guard lhs.slidesContent.count == rhs.slidesContent.count else {
                return false
            }
            for (key, lhsValue) in lhs.slidesContent {
                guard let rhsValue = rhs.slidesContent[key], lhsValue == rhsValue else {
                    return false
                }
            }
            
            return lhs.slidesCount == rhs.slidesCount &&
                   lhs.slideDuration == rhs.slideDuration &&
                   lhs.currentSlide == rhs.currentSlide &&
                   lhs.currentSlideContent == rhs.currentSlideContent &&
                   lhs.isSignInNavigationActive == rhs.isSignInNavigationActive &&
                   lhs.isSignUpNavigationActive == rhs.isSignUpNavigationActive
        }
        
        //deps
        var signInState: SignInFeature.State = SignInFeature.State()
    }
    
    enum Action{
        case asignSlideContent(Int)
        case slideChanged

        case signInButtonTapped
        case signUpButtonTapped
        
        case startTimer
        
        case signInAction(SignInFeature.Action)
    }
    
    var body: some ReducerOf<Self>{
        Scope(state: \.signInState, action: \.signInAction) {
            SignInFeature()
        }
        
        Reduce{
            state, action in
            switch action{
            case .signInAction:
                return .none
                
            case .slideChanged:
                if state.currentSlide < state.slidesCount - 1 {
                    state.currentSlide += 1
                } else {
                    state.currentSlide = 0
                }
                return .send(.asignSlideContent(state.currentSlide))
                
            case .signInButtonTapped:
                state.isSignInNavigationActive = true
                Logger.shared.log(.info, "signInButtonTapped\nstate.isSignInNavigationActive = \(state.isSignInNavigationActive)")
                return .none
                
            case .signUpButtonTapped:
                state.isSignUpNavigationActive = true
                Logger.shared.log(.info, "signUpButtonTapped\nstate.isSignUpNavigationActive = \(state.isSignUpNavigationActive)")
                return .none
                
            case .asignSlideContent(let index):
                state.currentSlideContent = state.slidesContent[index] ?? ("Упс!", "Возникла небольшая проблемка и мы не смогли загрузить для Вас слайд")
                return .none
                
            case .startTimer:
                state.isSignInNavigationActive = false
                state.isSignUpNavigationActive = false
                Logger.shared.log(.info, "state.isSignInNavigationActive = \(state.isSignInNavigationActive) \n state.isSignUpNavigationActive = \(state.isSignUpNavigationActive)")
                
                //state.currentSlide = 0
                
                if state.currentSlideContent == ("",""){
                    state.currentSlideContent = state.slidesContent[state.currentSlide] ?? ("Упс!", "Возникла небольшая проблемка и мы не смогли загрузить для Вас слайд")
                }
                
                let slideDuration = state.slideDuration
                return .run { send in
                    while true {
                        try await Task.sleep(for: .seconds(slideDuration))
                        await send(.slideChanged)
                    }
                }
                .cancellable(id: "slideTimer")
            }
        }
    }
}
