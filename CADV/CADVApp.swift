//
//  CADVApp.swift
//  CADV
//
//  Created by Misha Vakhrushin on 03.09.2024.
//

import RealmSwift
import FirebaseCore
import SwiftUI
import UserNotifications
import ComposableArchitecture

@main
struct CADVApp: App {
    @StateObject private var notificationManager = NotificationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State()
                ) {
                    AppFeature()
                }
            ).environmentObject(notificationManager)

            //RootView().environmentObject(notificationManager)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var isCheckingToken = false
    @State private var isAuthenticated: Bool = false {
        didSet {
            guard oldValue != isAuthenticated else { return }
            Logger.shared.log(.info, "Authentication status changed: \(isAuthenticated)")
        }
    }

    var body: some View {
        Group {
            if isAuthenticated {
                LocalAuthView()
                    .preferredColorScheme(.light)
            } else {
                SplashScreenView()
                    .preferredColorScheme(.light)
                    .onAppear {
                        notificationManager.requestPermission()
                    }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                print("Realm file size: \(totalBytes) bytes, used: \(usedBytes) bytes")
                return false
            }
        )

        return true
    }
}
