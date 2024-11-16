//
//  NotificationManager.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.11.2024.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
    
    // Запрашиваем разрешение на отправку уведомлений
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
            } else {
                print("Разрешение на уведомления отклонено")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Отправка локального уведомления
    func sendLocalNotification(withCode: String) {
        let content = UNMutableNotificationContent()
        content.title = "Код подтверждения"
        content.body = "Ваш код подтверждения: \(withCode)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "confirmationCodeNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка отправки уведомления: \(error.localizedDescription)")
            } else {
                print("Уведомление отправлено")
            }
        }
    }
}

// Расширение для обработки уведомлений при активном приложении
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])  // Показываем уведомление даже когда приложение активно
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Уведомление нажато: \(response.notification.request.content.body)")
        completionHandler()
    }
}
