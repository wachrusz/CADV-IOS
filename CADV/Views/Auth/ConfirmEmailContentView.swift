//
//  ConfirmEmailContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 16.09.2024.
//

import SwiftUI
import UIKit
import UserNotifications
import CoreData

class CustomCodeTextField: UITextField {
    var onDeleteBackward: (() -> Void)?
    
    override func deleteBackward() {
        onDeleteBackward?()
        super.deleteBackward()
    }
}

struct CustomCodeTextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    var onDeleteBackward: () -> Void
    var isFirstResponder: Bool = false
    
    func makeUIView(context: Context) -> CustomCodeTextField {
        let textField = CustomCodeTextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        textField.keyboardType = .numberPad
        
        textField.textColor = .black
        
        textField.onDeleteBackward = onDeleteBackward
        return textField
    }

    
    func updateUIView(_ uiView: CustomCodeTextField, context: Context) {
        uiView.text = text
        
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomCodeTextFieldWrapper
        
        init(_ parent: CustomCodeTextFieldWrapper) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textFieldText = textField.text as NSString? else { return false }
            let newText = textFieldText.replacingCharacters(in: range, with: string)
            if newText.count <= 1 {
                parent.text = newText
                return true
            }
            return false
        }
    }
}

struct EnterVerificationEmailCode: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var code: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedField: Int?
    @State private var showErrorView = false
    @State private var isNavigationActive = false
    @Binding var email: String
    @Binding var token: String
    @State var confirmationError: String?
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State var remainingAttempts: Int = 0
    @State var lockDuration: Int = 0
    @State private var resetToken: String = ""
    
    var isNew: Bool
    private let correctCode = "0000"
    var previousScreenName: String
    var isReset: Bool {
        previousScreenName == "Восстановление пароля"
    }
    @Binding var urlElements: URLElements?
    
    
    var body: some View {
        NavigationStack{
            ZStack {
                VStack {
                    VStack(spacing: 10) {
                        HStack(spacing: 20) {
                            if isReset {
                                StepView(number: "1", currentStep: 2, stepIndex: 1)
                                StepView(number: "2", currentStep: 2, stepIndex: 2)
                                StepView(number: "3", currentStep: 2, stepIndex: 3)
                            }else{
                                StepView(number: "1", currentStep: 2, stepIndex: 1)
                                StepView(number: "2", currentStep: 2, stepIndex: 2)
                            }
                        }
                        .padding()
                        
                        
                        CustomText(
                            text: "Подтверждение",
                            font: Font.custom("Inter", size: 12).weight(.semibold),
                            color: Color("fg")
                        )
                    }
                    Spacer().frame(minHeight: 10, idealHeight: 30, maxHeight: 30).fixedSize()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        CustomText(
                            text: "Введите код из письма",
                            font: Font.custom("Inter", size: 16).weight(.semibold),
                            color: Color("fg")
                        )
                        
                        HStack(spacing: 10) {
                            ForEach(0..<4, id: \.self) { index in
                                CustomCodeTextFieldWrapper(
                                    text: Binding(
                                        get: { code[index] },
                                        set: { newValue in
                                            if newValue.count == 1 {
                                                code[index] = newValue
                                                focusedField = index + 1 < 4 ? index + 1 : nil
                                            }
                                            if index == 3 && newValue.count == 1 {
                                                Task{
                                                    focusedField = 0
                                                    await validateCode()
                                                }
                                            }
                                        }
                                    ),
                                    onDeleteBackward: {
                                        if code[index].isEmpty && index > 0 {
                                            focusedField = index - 1
                                        }
                                        code[index] = ""
                                    },
                                    isFirstResponder: focusedField == index
                                )
                                .frame(width: 50, height: 50)
                                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                                .focused($focusedField, equals: index)
                            }
                        }
                        .onAppear {
                            focusedField = nil
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 20) {
                        HStack {
                            CustomText(
                                text: "Выслать ещё раз",
                                font: Font.custom("Inter", size: 14).weight(.semibold),
                                color: Color("fg")
                            )
                            
                            CustomText(
                                text: "Не приходит код",
                                font: Font.custom("Inter", size: 14).weight(.semibold),
                                color: Color("m3")
                            )
                        }
                        .padding(.horizontal)
                    }
                    Spacer(minLength: -keyboardHeight)
                    if isReset {
                        NavigationLink(
                            destination: ChangePasswordView(
                                email: $email,
                                token: $resetToken,
                                urlElements: $urlElements
                            ),
                            isActive: $isNavigationActive) {
                                EmptyView()
                            }
                    }else{
                        NavigationLink(
                            destination: LocalAuthView(urlElements: $urlElements),
                            isActive: $isNavigationActive) {
                                EmptyView()
                            }
                    }
                }.onAppear {
                    notificationManager.requestPermission()
                }
                
                if showErrorView {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showErrorView = false
                            }
                        }
                    VStack {
                        ErrorWrongCode()
                            .transition(.opacity)
                            .zIndex(1)
                    }
                    .onAppear {
                        UIApplication.shared.endEditing()
                    }
                }
            }
        }
        .colorScheme(.light)
        .navigationTitle("Подтверждение")
        .onAppear {
            focusedField = nil
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    private func validateCode() async{
        let enteredCode = code.joined()
        let parameters = [
            "code": enteredCode,
            "token": token
        ]
        do {
            let response = try await self.urlElements?.fetchData(
            endpoint: isReset ? "v1/auth/password/confirm" : (isNew ? "v1/auth/register/confirm" : "v1/auth/login/confirm"),
            parameters: parameters
        )
            if !isReset {
                switch response?["status_code"] as? Int {
                case 200:
                    print("case 200")
                    urlElements?.saveTokenData(responseObject: response ?? [:])
                    print(urlElements)
                    self.isNavigationActive = true
                    return
                case 400:
                    print("case 400")
                    let errorMessage = response?["error"] as? String ?? ""
                    self.confirmationError = errorMessage
                    return
                default:
                    let errorMessage = response?["error"] as? String ?? ""
                    print(errorMessage)
                    self.confirmationError = errorMessage
                    return
                }
            }
            
            let resetTokenDetails = response?["token_details"] as? [String : Any] ?? [:]
            self.resetToken = resetTokenDetails["reset_token"] as? String ?? ""
            self.isNavigationActive = true
        }
        catch let error{
            print(error)
        }
    }
    
    @State var errorMessage: String = ""
    @State var isCodeSent: Bool = false
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            } else if granted {
                print("Permission granted for notifications.")
            } else {
                print("Permission denied for notifications.")
            }
        }
    }
}

func sendLocalNotification(withCode code: String) {
    let content = UNMutableNotificationContent()
    content.title = "Подтверждение кода"
    content.body = "Ваш код подтверждения: \(code)"
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    let request = UNNotificationRequest(identifier: "confirmationCode", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
        } else {
            print("Уведомление успешно добавлено")
        }
    }
}


extension UIApplication {
    func endEditing() {
        windows.first?.endEditing(true)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let code = response.notification.request.content.body
        print("Код подтверждения: \(code)")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
