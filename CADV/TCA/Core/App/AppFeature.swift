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
        
        var splashScreenState = SplashScreenFeature.State()
        var startViewState = StartViewFeature.State()
        //var analyticsState = AnalyticsState()
    }
    
    enum Action {
        
        //Depandant Actions should be placed below
        
        case splashScreenAction(SplashScreenFeature.Action)
        case startViewAction(StartViewFeature.Action)
        //case analyticsAction(AnalyticsAction)
    }
    
    var body: some ReducerOf<Self> {
        
        //Place for Scopes
        
        Scope(state: \.splashScreenState, action: \.splashScreenAction) {
            SplashScreenFeature()
        }
        
        Scope(state: \.startViewState, action: \.startViewAction) {
            StartViewFeature()
        }
        
        /*
         Scope(state: \.analyticsState, action: \.analyticsAction) {
         AnalyticsFeature()
         }
         */
        
        //Reducer
        Reduce { state, action in
            switch action {
                
            case .splashScreenAction, .startViewAction:
                return .none
            }
        }
    }
}
