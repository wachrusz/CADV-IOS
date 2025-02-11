//
//  SplashScreenFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 07.02.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SplashScreenFeature {
    struct State: Equatable {
        
        //Internal States should be placed below
        
        var isActive = false
        var isExpanded = false
        var showAppIcon = false
        var logged = false
        
        //Depandant States should be placed below

    }

    enum Action: BindableAction {
        
        //Internal Actions should be placed below
        
        case binding(BindingAction<State>)
        case onAppear
        case startAnimations
        case setIsExpanded(Bool)
        case setShowAppIcon(Bool)
        case setIsActive(Bool)
        //Dependant Actions should be placed below
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.startAnimations)
                }

            case .startAnimations:
                return .concatenate(
                    .run { send in
                        await send(.setIsExpanded(true))
                        try await Task.sleep(for: .seconds(0.5))
                        await send(.setIsExpanded(false))
                        try await Task.sleep(for: .seconds(0.5))
                        await send(.setShowAppIcon(true))
                        try await Task.sleep(for: .seconds(0.5))
                        await send(.setIsActive(true))
                    }
                )

            case .setIsExpanded(let isExpanded):
                state.isExpanded = isExpanded
                return .none

            case .setShowAppIcon(let showAppIcon):
                state.showAppIcon = showAppIcon
                return .none

            case .setIsActive(let isActive):
                state.isActive = isActive
                return .none

            case .binding:
                return .none
            }
        }
    }
}
