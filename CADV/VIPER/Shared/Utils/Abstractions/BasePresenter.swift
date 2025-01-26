//
//  BasePresenter.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

class BasePresenter<InteractorType: InteractorProtocol, RouterType: RouterProtocol>: PresenterProtocol {
    var interactor: InteractorType
    var router: RouterType

    init(interactor: InteractorType, router: RouterType) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear() {
        // Базовая реализация (можно переопределить в дочерних классах)
    }
}
