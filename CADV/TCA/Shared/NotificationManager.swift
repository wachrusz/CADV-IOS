//
//  NotificationManager.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                Logger.shared.log(.info, "Notification permission granted")
            } else {
                Logger.shared.log(.info,"Разрешение на уведомления отклонено")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func sendLocalNotification(withCode: String) {
        let content = UNMutableNotificationContent()
        content.title = "Код подтверждения"
        content.body = "Ваш код подтверждения: \(withCode)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "confirmationCodeNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.log(.warning, "Ошибка отправки уведомления: \(error.localizedDescription)")
            } else {
                Logger.shared.log(.info, "Уведомление отправлено")
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.shared.log(.info, "Уведомление нажато: \(response.notification.request.content.body)")
        completionHandler()
    }
}
