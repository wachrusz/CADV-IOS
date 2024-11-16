//
//  CADVApp.swift
//  CADV
//
//  Created by Misha Vakhrushin on 03.09.2024.
//

import SwiftUI
import UserNotifications

@main
struct CADVApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject private var notificationManager = NotificationManager()
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
                .onAppear {
                    notificationManager.requestPermission()
                    for family in UIFont.familyNames { print(family) }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
