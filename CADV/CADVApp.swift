//
//  CADVApp.swift
//  CADV
//
//  Created by Misha Vakhrushin on 03.09.2024.
//

import SwiftUI
import UserNotifications
import CoreData

@main
struct CADVApp: App {
    let persistenceController = PersistenceController.shared
    
    @State       private var isCheckingToken       = false
    @StateObject private var notificationManager   = NotificationManager()
    @State       private var isAuthenticated: Bool = false {
        didSet {
            guard oldValue != isAuthenticated else { return }
            
            print("Authentication status changed: \(isAuthenticated)")
        }
    }
    @State private var urlElements: URLElements?
    
    var body: some Scene {
        WindowGroup {
            if let _ = urlElements {
                if isAuthenticated {
                    LocalAuthView(urlElements: $urlElements)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .preferredColorScheme(.light)
                } else {
                    SplashScreenView(urlElements: $urlElements)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .preferredColorScheme(.light)
                        .onAppear {
                            notificationManager.requestPermission()
                            checkToken()
                        }
                }
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        initializeURLElements()
                    }
            }
        }
    }
    
    private func initializeURLElements() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<AccessEntity> = AccessEntity.fetchRequest()
        
        do {
            let tokens = try context.fetch(fetchRequest)
            if tokens.isEmpty {
                print("Core Data is empty, creating default token")
                createDefaultToken()
                urlElements = URLElements(
                    tokenData: TokenData(from: AccessEntity(context: context)),
                    viewCtx: context
                )
                isAuthenticated = false
                print(urlElements as Any)
            } else if let entity = tokens.first {
                let tokenData = TokenData(from: entity)
                urlElements = URLElements(tokenData: tokenData, viewCtx: context)
                isAuthenticated = isValid(token: tokenData)
                print(urlElements as Any)
            } else {
                print("No token found, initializing default URL elements")
                urlElements = URLElements(
                    tokenData: TokenData(from: AccessEntity(context: context)),
                    viewCtx: context
                )
                isAuthenticated = false
                print(urlElements as Any)
            }
        } catch {
            print("Error fetching token: \(error)")
            isAuthenticated = false
            print(urlElements as Any)
        }
    }
    
    private func checkToken(attemptsLeft: Int = 3) {
        guard !isCheckingToken else { return }
        isCheckingToken = true
            
        defer { isCheckingToken = false }
        print("Started checking tokens, attempts left: \(attemptsLeft)")
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<AccessEntity> = AccessEntity.fetchRequest()
        
        do {
            let tokens = try context.fetch(fetchRequest)
            if tokens.isEmpty {
                print("Core Data is empty, creating default token")
                createDefaultToken()
                isAuthenticated = false
                return
            }
            
            if let entity = tokens.first {
                print("Found token entity")
                let tokenData = TokenData(from: entity)
                
                if isValid(token: tokenData) {
                    print("Token is valid")
                    isAuthenticated = true
                    return
                } else {
                    print("Token is invalid")
                    
                    if attemptsLeft > 0 {
                        urlElements?.refreshTokenIfNeeded() { success in
                            if success {
                                print("Token refreshed successfully, rechecking...")
                                self.initializeURLElements()
                                self.checkToken(attemptsLeft: attemptsLeft - 1)
                            } else {
                                print("Failed to refresh token, attempts left: \(attemptsLeft - 1)")
                                self.checkToken(attemptsLeft: attemptsLeft - 1)
                            }
                        }
                    } else {
                        print("All attempts exhausted, authentication failed")
                        isAuthenticated = false
                    }
                }
            } else {
                print("No token found, setting isAuthenticated to false")
                isAuthenticated = false
            }
        } catch {
            print("Error fetching token: \(error)")
            isAuthenticated = false
        }
    }
    
    private func isValid(token: TokenData) -> Bool {
        print("exp: \(token.accessTokenExpiresAt), curr: \(Date())")
        return token.accessTokenExpiresAt > Date()
    }
    
    private func createDefaultToken() {
        let context = persistenceController.container.viewContext
        let newToken = AccessEntity(context: context)
        newToken.accessToken = "default_access_token"
        newToken.refreshToken = "default_refresh_token"
        newToken.accessTokenExpiresAt = Date().addingTimeInterval(-10000)
        newToken.refreshTokenLifeTime = 3600
        
        do {
            try context.save()
            print("Default token created")
        } catch {
            print("Failed to create default token: \(error.localizedDescription)")
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
