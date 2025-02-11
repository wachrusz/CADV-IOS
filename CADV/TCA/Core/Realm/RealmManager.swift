//
//  RealmManager.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import RealmSwift

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
