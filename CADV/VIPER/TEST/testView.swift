//
//  test.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var presenter: HomePresenter

    var body: some View {
        NavigationStack(path: $presenter.router.navigationPath) {
            VStack {
                Text("Home Screen")
                Button("Go to Next Screen") {
                    Logger.shared.log(.info, "pressed button Go to Next Screen")
                    self.presenter.router.navigateToNextScreen()
                }
                Button("Go Back") {
                    Logger.shared.log(.info, "pressed button Go Back")
                    self.presenter.router.navigateBack()
                }
                Button("Go to Root") {
                    Logger.shared.log(.info, "pressed button Go Root")
                    self.presenter.router.navigateToRoot()
                }
            }
            .navigationTitle("Home")
            /*
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {
                case .next:
                    NextView()
                case .home:
                    HomeConfigurator.configure()
                }
            }
             */
        }
    }
}
