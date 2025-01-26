//
//  testPresenter.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import SwiftUI
import Combine

class HomePresenter: PresenterProtocol {
    var interactor: HomeInteractor
    var router: HomeRouter

    init(interactor: HomeInteractor, router: HomeRouter) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear() {
        interactor.fetchData { entity in
            print("Fetched data: \(entity.title)")
        }
    }
}
