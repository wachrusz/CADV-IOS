//
//  AppFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State: Equatable {
        var isAuthenticated: Bool = false
        var isCheckingToken: Bool = false
        
        //Depandant States should be placed below
        
        var onboardingState = OnboardingFeature.State()
    }
    
    enum Action {
        
        //Depandant Actions should be placed below
        
        case onboardingAction(OnboardingFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        
        //Place for Scopes
        
        Scope(state: \.onboardingState, action: \.onboardingAction) {
            OnboardingFeature()
        }
        
        //Reducer
        Reduce { state, action in
            switch action {
            case .onboardingAction:
                return .none
            }
                
        }
    }
}
