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
    
    var query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == noErr, let data = dataTypeRef as? Data, let identifier = String(data: data, encoding: .utf8) {
        return identifier
    } else {
        let newIdentifier = UUID().uuidString
        let data = newIdentifier.data(using: .utf8)!
        
        query[kSecValueData as String] = data
        SecItemAdd(query as CFDictionary, nil)
        
        return newIdentifier
    }
}
