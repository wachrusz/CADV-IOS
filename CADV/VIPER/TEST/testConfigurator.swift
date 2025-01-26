//
//  testConfigurator.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

class HomeConfigurator {
    static func configure() -> HomeView {
        let interactor = HomeInteractor()
        let router = HomeRouter()
        let presenter = HomePresenter(interactor: interactor, router: router)
        return HomeView(presenter: presenter)
    }
}
