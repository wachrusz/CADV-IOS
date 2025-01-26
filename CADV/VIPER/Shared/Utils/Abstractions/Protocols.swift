//
//  AbstractPresenter.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import SwiftUI

protocol ViewProtocol: AnyObject {
    associatedtype PresenterType: PresenterProtocol
    var presenter: PresenterType { get set }
}

protocol PresenterProtocol: ObservableObject {
    associatedtype InteractorType: InteractorProtocol
    associatedtype RouterType: RouterProtocol

    var interactor: InteractorType { get set }
    var router: RouterType { get set }

    func viewDidAppear()
}

protocol InteractorProtocol {
    associatedtype EntityType: EntityProtocol
    func fetchData(completion: @escaping (EntityType) -> Void)
}

protocol EntityProtocol: Identifiable {
    var id: UUID { get }
}
