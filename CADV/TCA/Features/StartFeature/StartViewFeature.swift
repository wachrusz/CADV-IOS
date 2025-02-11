//
//  StartViewFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.02.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct StartViewFeature {
    struct State: Equatable {
        
        //Internal States should be placed below
        
        var isVisible: Bool = false
        var startMovement: Bool = false
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
        
        //Dependant States should be placed below
        
    }

    enum Action: BindableAction {
        //Internal Actions should be placed below
        case binding(BindingAction<State>)
        case onAppear
        case startAnimations
        case setIsVisible(Bool)
        case setStartMovement(Bool)
        case logAnalyticsEvent(String, [String: Any]?)
        
        //Dependant Actions should be placed below
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.logAnalyticsEvent("app_started", nil))
                    await send(.startAnimations)
                }

            case .startAnimations:
                return .run { send in
                    // Запуск анимации для хэштегов
                    for index in 0..<15 { // 15 — количество хэштегов
                        try await Task.sleep(for: .seconds(0.1))
                        await send(.setIsVisible(true))
                    }

                    // Запуск анимации для нижней панели
                    try await Task.sleep(for: .seconds(0.6))
                    await send(.setStartMovement(true))
                }

            case .setIsVisible(let isVisible):
                state.isVisible = isVisible
                return .none

            case .setStartMovement(let startMovement):
                state.startMovement = startMovement
                return .none

            case .logAnalyticsEvent(let eventType, let additionalData):
                // Логирование аналитики
                FirebaseAnalyticsManager.shared.logUserActionEvent(
                    userId: getDeviceIdentifier(),
                    actionType: eventType,
                    screenName: "NewUser",
                    additionalData: additionalData
                )
                return .none

            case .binding:
                return .none
            }
        }
    }
}
