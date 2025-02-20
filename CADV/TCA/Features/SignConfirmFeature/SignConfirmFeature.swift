//
//  SignConfirmFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 20.02.2025.
//

//TODO: Complete this shit
import ComposableArchitecture

@Reducer
struct SignConfirmFeature{
    @ObservableState
    struct State: Equatable{
        var code: String = ""
        var isCodeEntered: Bool = false
        var isCorrect: Bool = false
    }
    
    enum Action{
        case codeChanged(String)
        case tappedForgotButton
    }
    
    var body: some ReducerOf<Self>{
        Reduce{
            state, action in
            switch action{
            case .codeChanged(let data):
                state.code = data
                return .none
            case .tappedForgotButton:
                
                /*
                 CODE HERE
                 */
                
                return .none
            }
        }
    }
}
