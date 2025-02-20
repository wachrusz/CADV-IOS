//
//  SignInFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 14.02.2025.
//

import ComposableArchitecture

@Reducer
struct SignInFeature{
    @ObservableState
    struct State: Equatable{
        var isPhoneAuth: Bool = true
        
        let headersContent: [Bool : (String, String)] = [
            true : ("Введите номер  телефона",
                 "Используйте, чтобы войти или стать  нашим клиентом"),
            false : ("Введите вашу электронную почту",
                 "Используйте контактную почту, чтобы войти или стать нашим клиентом")
        ]
        var currentHeaderContent: (String, String) = ("", "")
        
        var promtContent: [Bool: String] = [
            true : "+7 (XXX) XXX-XX-XX",
            false : "cashadvisor@mail.ru"
        ]
        
        var currentPromt: String = ""
        
        let buttonsContent: [Bool: String] = [
            true : "Войти по E-mail",
            false : "Войти по номеру телефона"
        ]
        var currentButtonContent: String = ""
        
        var inputFieldData: String = ""
        
        static func == (lhs: State, rhs: State) -> Bool {
            guard lhs.headersContent.count == rhs.headersContent.count else {
                return false
            }
            for (key, lhsValue) in lhs.headersContent {
                guard let rhsValue = rhs.headersContent[key], lhsValue.0 == rhsValue.0, lhsValue.1 == rhsValue.1 else {
                    return false
                }
            }
            
            return lhs.isPhoneAuth == rhs.isPhoneAuth &&
                   lhs.currentHeaderContent == rhs.currentHeaderContent &&
                   lhs.buttonsContent == rhs.buttonsContent &&
                   lhs.currentButtonContent == rhs.currentButtonContent &&
                   lhs.inputFieldData == rhs.inputFieldData
        }
    }
    
    enum Action{
        case continueButtonTapped
        case switchAuthMethod
        case changeAuthMethodButtonTapped
        
        case viewAppeared
        case inputFieldDataChanged(String)
        
        case isPhoneAuthBinding(Bool)
        
    }
    
    var body: some ReducerOf<Self>{
        Reduce{
            state, action in
            switch action{
            case .isPhoneAuthBinding:
                return .none
                
            case .continueButtonTapped:
                return .none
                
            case .switchAuthMethod:
                state.isPhoneAuth = !state.isPhoneAuth
                state.currentButtonContent = state.buttonsContent[state.isPhoneAuth] ?? "Error"
                state.currentHeaderContent = state.headersContent[state.isPhoneAuth] ?? ("Упс!", "Возникла небольшая проблемка и мы не смогли загрузить для Вас заголовок")
                state.currentPromt = state.promtContent[state.isPhoneAuth] ?? "OI OI OI"
                state.inputFieldData = ""
                Logger.shared.log(.warning, state.inputFieldData)
                return . none
                
            case .changeAuthMethodButtonTapped:
                return .send(.switchAuthMethod)
                
            case .viewAppeared:
                state.currentButtonContent = state.buttonsContent[state.isPhoneAuth] ?? "Error"
                state.currentHeaderContent = state.headersContent[state.isPhoneAuth] ?? ("Упс!", "Возникла небольшая проблемка и мы не смогли загрузить для Вас заголовок")
                state.currentPromt = state.promtContent[state.isPhoneAuth] ?? "OI OI OI"
                
            case .inputFieldDataChanged(let data):
                state.inputFieldData = data
                return .none
                
            }
            return .none
        }
    }
}
