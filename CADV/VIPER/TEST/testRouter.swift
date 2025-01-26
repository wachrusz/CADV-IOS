//
//  testRouter.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import SwiftUI

class HomeRouter: BaseRouter {
    func navigateToNextScreen() {
        Logger.shared.log(.info, "Navigating to .next")
        navigate(.push(.next))
    }

    func navigateBack() {
        navigate(.pop)
    }

    func navigateToRoot() {
        navigate(.popToRoot)
    }
}
