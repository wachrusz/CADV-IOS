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

@main
struct CADVApp: App {
    @StateObject private var notificationManager = NotificationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            //RootView()
            //    .environmentObject(notificationManager)
            HomeConfigurator.configure()
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
                        checkToken()
                    }
            }
        }
        .onAppear {
            initializeURLElements()
        }
    }

    private func initializeURLElements() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.initializeURLElements()
            }
            return
        }

        if let tokenEntity = RealmManager.shared.realm.objects(TokenEntity.self).first {
            let tokenData = TokenData(
                accessToken: tokenEntity.accessToken,
                refreshToken: tokenEntity.refreshToken,
                accessTokenExpiresAt: tokenEntity.accessTokenExpiresAt,
                refreshTokenExpiresAt: tokenEntity.refreshTokenExpiresAt
            )
            isAuthenticated = isValid(token: tokenData)
            Logger.shared.log(.info, "URL elements initialized with existing token")
        } else {
            Logger.shared.log(.warning, "Realm is empty, creating default token")
            createDefaultToken()
            if let tokenEntity = RealmManager.shared.realm.objects(TokenEntity.self).first {
                let tokenData = TokenData(
                    accessToken: tokenEntity.accessToken,
                    refreshToken: tokenEntity.refreshToken,
                    accessTokenExpiresAt: tokenEntity.accessTokenExpiresAt,
                    refreshTokenExpiresAt: tokenEntity.refreshTokenExpiresAt
                )
                isAuthenticated = false
                Logger.shared.log(.info, "URL elements initialized with default token")
            }
        }
    }

    private func checkToken(attemptsLeft: Int = 3) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.checkToken(attemptsLeft: attemptsLeft)
            }
            return
        }
        guard !isCheckingToken else { return }
        isCheckingToken = true

        defer { isCheckingToken = false }
        Logger.shared.log(.info, "Started checking tokens, attempts left: \(attemptsLeft)")

        let tokenData = URLElements.shared.tokenData

        if isValid(token: tokenData) {
            Logger.shared.log(.info, "Token is valid")
            isAuthenticated = true
            return
        } else {
            Logger.shared.log(.warning, "Token is invalid")

            if attemptsLeft > 0 {
                URLElements.shared.refreshTokenIfNeeded { success in
                    if success {
                        Logger.shared.log(.info, "Token refreshed successfully, rechecking...")
                        self.checkToken(attemptsLeft: attemptsLeft - 1)
                    } else {
                        Logger.shared.log(.warning, "Failed to refresh token, attempts left: \(attemptsLeft - 1)")
                        self.checkToken(attemptsLeft: attemptsLeft - 1)
                    }
                }
            } else {
                if KeychainHelper.shared.read(forKey: "user_pin_code") != nil {
                    KeychainHelper.shared.delete(forKey: "user_pin_code")
                }
                Logger.shared.log(.error, "All attempts exhausted, authentication failed")
                isAuthenticated = false
            }
        }
    }

    private func isValid(token: TokenData) -> Bool {
        Logger.shared.log(.info, "exp: \(token.accessTokenExpiresAt), curr: \(Date())")
        return token.accessTokenExpiresAt > Date()
    }

    private func createDefaultToken() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.createDefaultToken()
            }
            return
        }
        RealmManager.shared.realm.deleteAll()
        if KeychainHelper.shared.read(forKey: "user_pin_code") != nil {
            KeychainHelper.shared.delete(forKey: "user_pin_code")
        }

        let tokenEntity = TokenEntity()
        tokenEntity.deviceID = getDeviceIdentifier()
        tokenEntity.accessToken = "default_access_token"
        tokenEntity.refreshToken = "default_refresh_token"
        tokenEntity.accessTokenExpiresAt = Date().addingTimeInterval(-10000)
        tokenEntity.refreshTokenExpiresAt = Date().addingTimeInterval(3600)

        do {
            try RealmManager.shared.realm.write {
                RealmManager.shared.realm.add(tokenEntity, update: .modified)
            }
            Logger.shared.log(.info, "Default token created")
        } catch {
            Logger.shared.log(.error, "Failed to create default token: \(error.localizedDescription)")
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

class RealmManager: ObservableObject {
    static let shared = RealmManager()
    let realm: Realm

    private init() {
        do {
            self.realm = try Realm()
            print("Realm created at \(Thread.current)")
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
}
