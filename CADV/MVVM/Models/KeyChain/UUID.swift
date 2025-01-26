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
    
    // Запрос для поиска существующего идентификатора
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    // Если идентификатор найден, возвращаем его
    if status == noErr, let data = dataTypeRef as? Data, let identifier = String(data: data, encoding: .utf8) {
        return identifier
    } else {
        // Если идентификатор не найден, создаем новый
        let newIdentifier = UUID().uuidString
        let data = newIdentifier.data(using: .utf8)
        
        // Удаляем старую запись (если есть)
        SecItemDelete(query as CFDictionary)
        
        // Создаем новую запись в Keychain
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock // Убедитесь, что данные доступны после первого разблокирования
        ]
        
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        
        if addStatus == noErr {
            return newIdentifier
        } else {
            // Если не удалось сохранить в Keychain, возвращаем новый идентификатор (но это нежелательно)
            print("Ошибка при сохранении в Keychain: \(addStatus)")
            return newIdentifier
        }
    }
}
