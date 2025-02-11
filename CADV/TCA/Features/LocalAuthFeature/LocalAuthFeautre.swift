//
//  LocalAuthFeautre.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.02.2025.
//

import SwiftUI
import LocalAuthentication
import ComposableArchitecture

@Reducer
struct LocalAuthFeature {
    @ObservableState
    struct State: Equatable {
        var codeExists: Bool = true
        var enteredCode: String = ""
        var isCodeValid: Bool = false
        var circleColors: [Color] = Array(repeating: .gray, count: 6)
        var shakeOffset: CGFloat = 0
        var showFaceIDPrompt: Bool = false
        var circlesScale: CGFloat = 1.0
        let codeLength: Int = 6
        let keychainKey: String = "user_pin_code"
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addDigit(String)
        case removeDigit
        case checkCode
        case setupUserPinCode(String)
        case authenticateWithBiometrics
        case faceIDEnabled(Bool)
        case shake(Bool)
        case toggleFaceIDPrompt(Bool)
        case updateShakeOffset(CGFloat)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addDigit(let digit):
                guard state.enteredCode.count < state.codeLength else { return .none }
                state.enteredCode.append(digit)
                if state.enteredCode.count == state.codeLength {
                    return .send(.checkCode)
                }
            
            case .removeDigit:
                guard !state.enteredCode.isEmpty else { return .none }
                state.enteredCode.removeLast()
            
            case .checkCode:
                if !state.codeExists {
                    return .send(.setupUserPinCode(state.enteredCode))
                }
                if let savedCode = KeychainHelper.shared.read(forKey: state.keychainKey),
                   state.enteredCode == savedCode {
                    state.circleColors = Array(repeating: .green, count: state.codeLength)
                    state.circlesScale = 0.5
                    return .send(.shake(true))
                } else {
                    state.circleColors = Array(repeating: .red, count: state.codeLength)
                    return .send(.shake(false))
                }
            
            case .setupUserPinCode(let code):
                KeychainHelper.shared.save(code, forKey: state.keychainKey)
                state.codeExists = true
                return .send(.checkCode)
            
            case .authenticateWithBiometrics:
                return .run { send in
                    let context = LAContext()
                    var error: NSError?
                    
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        let reason = "Подтвердите свою личность."
                        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                            Task {
                                await send(.faceIDEnabled(success))
                            }
                        }
                    } else {
                        await send(.faceIDEnabled(false))
                    }
                }
            
            case .faceIDEnabled(let success):
                if success {
                    state.enteredCode = "______"
                    state.circleColors = Array(repeating: .green, count: state.codeLength)
                    state.circlesScale = 0.5
                    state.isCodeValid = true
                }
            
            case .shake(let isValid):
                if !isValid {
                    return .run { send in
                        await send(.updateShakeOffset(-10))
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        await send(.updateShakeOffset(10))
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        await send(.updateShakeOffset(0))
                    }
                }
                return .none

            case .updateShakeOffset(let offset):
                state.shakeOffset = offset
                return .none
            
            case .toggleFaceIDPrompt(let show):
                state.showFaceIDPrompt = show
                
            case .binding:
                return .none
            }
            return .none
        }
    }
}

