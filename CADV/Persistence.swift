//
//  Persistence.swift
//  CADV
//
//  Created by Misha Vakhrushin on 03.09.2024.
//

import Foundation
import RealmSwift
/*
// Объявляем модель данных Item
class Item: Object {
    @Persisted var timestamp: Date = Date()
}

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let realm = result.realm

        // Добавляем тестовые данные для превью
        try! realm.write {
            for _ in 0..<10 {
                let newItem = Item() // Создаем новый объект Item
                newItem.timestamp = Date()
                realm.add(newItem) // Добавляем объект в Realm
            }
        }
        return result
    }()

    let realm: Realm

    init(inMemory: Bool = false) {
        var configuration = Realm.Configuration()

        if inMemory {
            // Используем временную базу данных в памяти
            configuration.inMemoryIdentifier = "PreviewRealm"
        }

        do {
            realm = try Realm(configuration: configuration)
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
}
*/
