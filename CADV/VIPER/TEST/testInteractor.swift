//
//  testInteractor.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import Foundation

class HomeInteractor: InteractorProtocol {
    typealias EntityType = HomeEntity

    func fetchData(completion: @escaping (HomeEntity) -> Void) {
        let entity = HomeEntity(title: "Data from HomeInteractor")
        completion(entity)
    }
}
