//
//  BaseRouter.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import SwiftUI

enum NavigationType {
    case push(AppScreen)
    case pop
    case popToRoot
}

class BaseRouter: RouterProtocol, ObservableObject {
    @Published var navigationPath = NavigationPath() {
        didSet {
            Logger.shared.log(.info, "NavigationPath updated: \(navigationPath)")
        }
    }

    func navigate(_ type: NavigationType) {
        DispatchQueue.main.async {
            switch type {
            case .push(let screen):
                self.push(screen)
            case .pop:
                self.pop()
            case .popToRoot:
                self.popToRoot()
            }
        }
    }

    private func push(_ screen: AppScreen) {
        navigationPath.append(screen)
    }

    private func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    private func popToRoot() {
        navigationPath = NavigationPath()
    }
}
