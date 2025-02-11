//
//  Validators.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import Foundation

func textFieldValidatorEmail(_ string: String) -> Bool {
    if string.count > 64 || string.isEmpty || string.count < 2 {
        return false
    }
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: string)
}

func runOnMainThread(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
