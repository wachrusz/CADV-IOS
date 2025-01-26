//
//  BaseInteractor.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

class BaseInteractor<EntityType: EntityProtocol>: InteractorProtocol {
    func fetchData(completion: @escaping (EntityType) -> Void) {
        // Базовая реализация (можно переопределить в дочерних классах)
    }
}
