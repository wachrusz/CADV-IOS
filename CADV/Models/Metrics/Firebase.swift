//
//  Firebase.swift
//  CADV
//
//  Created by Misha Vakhrushin on 17.01.2025.
//

import Foundation
import FirebaseAnalytics
import Combine
import SwiftyJSON
import FirebaseCore

class FirebaseAnalyticsManager: ObservableObject {
    static let shared = FirebaseAnalyticsManager()

    private init() {}

    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        Logger.shared.log(.info, "Firebase Analytics: Logged event: \(name), parameters: \(parameters ?? [:])")
    }

    func logUserActionEvent(
        userId: String,
        actionType: String,
        screenName: String,
        additionalData: [String: Any]? = nil
    ) {
        var parameters: [String: Any] = [
            "device_id": userId,
            "action_type": actionType,
            "screen_name": screenName,
            "timestamp": Timestamp()
        ]

        if let userInfo = getUserInfo() {
            parameters.merge(userInfo) { (current, _) in current }
        }

        if let additionalData = additionalData {
            parameters.merge(additionalData) { (current, _) in current }
        }

        logEvent("user_action", parameters: parameters)
    }

    private func getUserInfo() -> [String: Any]? {
        let locale = Locale.current

        let country = locale.region ?? "Unknown"

        let region = locale.region?.containingRegion ?? "Unknown"
        
        let language = locale.language.languageCode ?? "Unknown"

        return [
            "country": country,
            "region": region,
            "language": language
        ]
    }

    func logComplexDataEvent(eventName: String, data: [String: Any]) {
        let json = JSON(data)

        if let jsonString = json.rawString() {
            let parameters: [String: Any] = [
                "data": jsonString
            ]
            logEvent(eventName, parameters: parameters)
        } else {
            Logger.shared.log(.error, "Firebase Analytics: Failed to convert data to JSON string")
        }
    }
}
