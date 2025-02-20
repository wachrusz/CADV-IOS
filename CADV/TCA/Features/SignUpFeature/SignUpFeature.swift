//
//  SignUpFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 19.02.2025.
//

import ComposableArchitecture

@Reducer
struct SignUpFeature{
    @ObservableState
    struct State{
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
        
        var isPhoneSignUp: Bool
        
        var currentHeaderContent: (String, String) = ("","")
        var currentStep = 0
        
        var headerContents: [Int: (String, String)] =
        [
            0: ("Для чего хотите использовать сервис?","Подскажем практики финансовой грамотности, которые нужны именно вам"),
            1: ("Введите номер  телефона","Используйте, чтобы войти или стать  нашим клиентом"),
            2: ("Введите вашу электронную почту","Используйте контактную почту, чтобы войти или стать нашим клиентом")
        ]
        
        var tags: [String: [String]] = [
            "Выберите что планируете отслеживать": [
                "Мои доходы",
                "Импульсивные траты",
                "Чеки и документы",
                "Мои расходы",
                "Динамику денег",
                "Другое",
            ],
            "Глобальные цели" : [
                "Обучение",
                "Развитие в инвестировании",
                "Рефинансирование",
                "Благополучие",
                "Защита от мошенников",
                "Бухгалтерия",
                "Планирование",
                "Другое"
            ]
        ]
    }
    
    enum Action{
        case stepChanged
        
        case completeAnalyticsdStep
        
        case completedSignUpStep
        
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
            switch action {
            case .viewAppeared:
                return .none
                
            case .inputFieldDataChanged(let data):
                state.inputFieldData = data
                return .none
                
            case .continueButtonTapped:
                return .none
                
            case .completedSignUpStep:
                return .none
                
            case .completeAnalyticsdStep:
                state.currentStep += 1
                return .none
                
            case .changeAuthMethodButtonTapped:
                return .send(.switchAuthMethod)
                
            case .switchAuthMethod:
                state.isPhoneSignUp = !state.isPhoneSignUp
                if state.isPhoneSignUp{
                    state.currentStep = 1
                }else{
                    state.currentStep = 2
                }
                state.currentButtonContent = state.buttonsContent[state.isPhoneSignUp] ?? "Error"
                state.currentHeaderContent = state.headerContents[state.currentStep] ?? ("Упс!", "Возникла небольшая проблемка и мы не смогли загрузить для Вас заголовок")
            case .stepChanged:
                state.currentStep += 1
                return .none
            case .isPhoneAuthBinding:
                return .none
            }
            return .none
        }
    }
}
