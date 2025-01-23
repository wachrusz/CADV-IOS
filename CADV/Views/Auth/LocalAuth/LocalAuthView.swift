//
//  LocalAuthView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 10.12.2024.
//

import SwiftUI
import LocalAuthentication

struct LocalAuthView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var urlElements: URLElements?
    @State private var codeExists:       Bool    = true
    @State private var enteredCode:      String  = ""
    @State private var isCodeValid:      Bool    = false
    @State private var circleColors:     [Color] = Array(repeating: .gray, count: 6)
    @State private var shakeOffset:      CGFloat = 0
    @State private var showFaceIDPrompt: Bool    = false
    @State private var circlesScale:     CGFloat = 1.0
           private let codeLength:       Int     = 6
           private let keychainKey:      String  = "user_pin_code"
    
    var body: some View {
        NavigationView {
            VStack {
                CustomText(
                    text: "Введите код для входа в приложение",
                    font: Font.custom("Gilroy", size: 16).weight(.semibold),
                    color: Color("fg")
                )
                
                HStack(spacing: 10) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        CodeFieldElement(
                            index: index,
                            enteredCode: $enteredCode,
                            circlesScale: $circlesScale,
                            circleColors: $circleColors
                        )
                    }
                }
                .padding(.bottom, 40)
                .offset(x: shakeOffset)
                .animation(.default, value: shakeOffset)
                
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 15) {
                            ForEach(1...3, id: \.self) { column in
                                let number = row * 3 + column
                                DigitElement(
                                    number: number,
                                    action: addDigit
                                )
                            }
                        }
                    }
                    HStack(spacing: 15) {
                        Button(action: {
                            if codeExists {
                                if !UserDefaults.standard.bool(forKey: "isFaceIDEnabled") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showFaceIDPrompt = true
                                    }
                                } else {
                                    authenticateWithBiometrics { success in
                                        if success {
                                            withAnimation {
                                                circleColors = Array(repeating: .green, count: codeLength)
                                                circlesScale = 0.5
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                isCodeValid = true
                                            }
                                        } else {
                                            Logger.shared.log(.info,"Face ID authentication failed")
                                        }
                                    }
                                }
                            } else {
                                
                            }
                        }) {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "faceid")
                                        .font(.title)
                                        .foregroundColor(.red)
                                )
                        }
                        
                        DigitElement(
                            number: 0,
                            action: addDigit
                        )
                        Button(action: removeDigit) {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "delete.left")
                                        .font(.title)
                                        .foregroundColor(.red)
                                )
                        }
                    }
                    Text("Delete")
                        .onTapGesture {
                            KeychainHelper.shared.delete(forKey: keychainKey)
                            Logger.shared.log(.info, "Deleted all occurencies of passwords and other confidential information")
                        }
                }
                .padding(.bottom, 40)
                
                NavigationLink(
                    destination: TabBarView(
                        urlElements: $urlElements
                    ),
                    isActive: $isCodeValid
                ) {
                    EmptyView()
                }
            }
            .hideBackButton()
            .padding()
            .onAppear(){
                if KeychainHelper.shared.read(forKey: keychainKey) == nil{
                    Logger.shared.log(.info, KeychainHelper.shared.read(forKey: keychainKey))
                    codeExists = false
                }else{
                    Logger.shared.log(.info, KeychainHelper.shared.read(forKey: keychainKey))
                }
                
                if UserDefaults.standard.bool(forKey: "isFaceIDEnabled") {
                    authenticateWithBiometrics { success in
                        if success {
                            enteredCode = "______"
                            withAnimation {
                                circleColors = Array(repeating: .green, count: codeLength)
                                circlesScale = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isCodeValid = true
                            }
                        }
                    }
                }
            }
            .hideBackButton()
            .alert(isPresented: $showFaceIDPrompt) {
                Alert(
                    title: Text("Быстрый вход"),
                    message: Text("Хотите включить Face ID для быстрого входа?"),
                    primaryButton: .default(Text("Да")) {
                        enableFaceID()
                    },
                    secondaryButton: .cancel(Text("Нет")) {
                    }
                )
            }
        }
    }
    
    private func addDigit(_ digit: String) {
        guard enteredCode.count < codeLength else { return }
        enteredCode.append(digit)
        
        if enteredCode.count == codeLength {
            checkCode()
        }
    }
    
    private func removeDigit() {
        guard !enteredCode.isEmpty else { return }
        enteredCode.removeLast()
    }
    
    private func checkCode() {
        if !codeExists {
            setupUserPinCode(enteredCode)
            codeExists = true
            checkCode()
        }else{
            if let savedCode = KeychainHelper.shared.read(forKey: keychainKey), enteredCode == savedCode {
                withAnimation {
                    circleColors = Array(repeating: .green, count: codeLength)
                    circlesScale = 0.5
                }
                
                shake(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCodeValid = true
                }
            } else {
                withAnimation {
                    circleColors = Array(repeating: .red, count: codeLength)
                    shake()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    circleColors = Array(repeating: .gray, count: codeLength)
                    enteredCode = ""
                }
            }
        }
    }
    
    private func setupUserPinCode(_ code: String) {
        let defaultPin = code
        KeychainHelper.shared.save(defaultPin, forKey: keychainKey)
    }
    
    private func enableFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Используйте Face ID для быстрого входа."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        Logger.shared.log(.info, "Face ID enabled successfully")
                        UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
                    } else {
                        Logger.shared.log(.error, "Face ID setup failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                Logger.shared.log(.error, "Face ID is not available: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    private func shake(_ isTrue: Bool = false) {
        if !isTrue {
            withAnimation(.default) {
                shakeOffset = -10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.default) {
                    shakeOffset = 10
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.default) {
                    shakeOffset = 0
                }
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }else{
        }
    }
    
    private func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Подтвердите свою личность для продолжения."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        Logger.shared.log(.info,"Biometric authentication successful")
                        completion(true)
                    } else {
                        Logger.shared.log(.error, "Biometric authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                        completion(false)
                    }
                }
            }
        } else {
            Logger.shared.log(.error, "Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            completion(false)
        }
    }
}

struct CodeFieldElement: View{
             var index:        Int
    @Binding var enteredCode:  String
    @Binding var circlesScale: CGFloat
    @Binding var circleColors: [Color]
    
    var body: some View{
        Circle()
            .stroke(lineWidth: 2)
            .frame(width: 20, height: 20)
            .background(index < enteredCode.count ? circleColors[index] : Color.clear)
            .clipShape(Circle())
            .scaleEffect(circlesScale)
            .animation(.spring(), value: circlesScale)
    }
}

struct DigitElement: View{
    let number: Int
    let action: (String) -> Void
    
    var body: some View{
        Button(action: {
            action("\(number)")
        }) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("\(number)")
                        .font(.title)
                        .foregroundColor(Color("fg"))
                )
        }
    }
}
