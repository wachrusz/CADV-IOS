//
//  UUID.swift
//  CADV
//
//  Created by Misha Vakhrushin on 15.01.2025.
//

import Foundation
import Security

func getDeviceIdentifier() -> String {
    let service = "com.wachrusz.CADV"
    let account = "deviceIdentifier"
    
    // Find UUID
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    // If Found return
    if status == noErr, let data = dataTypeRef as? Data, let identifier = String(data: data, encoding: .utf8) {
        return identifier
    } else {
        // Create new if not
        let newIdentifier = UUID().uuidString
        let data = newIdentifier.data(using: .utf8)
        
        // Delete the old one to be sure
        SecItemDelete(query as CFDictionary)
        
        // Create a new one
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            // to make sure that data is accesable after creating
        ]
        
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        
        if addStatus == noErr {
            return newIdentifier
        } else {
            // Error handling
            print("Ошибка при сохранении в Keychain: \(addStatus)")
            return newIdentifier
        }
    }
}
