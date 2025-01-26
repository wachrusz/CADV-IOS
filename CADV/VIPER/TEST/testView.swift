//
//  test.swift
//  CADV
//
//  Created by Misha Vakhrushin on 26.01.2025.
//

import SwiftUI

struct HomeView: View, ViewProtocol {
    @ObservedObject var presenter: HomePresenter

    var body: some View {
        NavigationView {
            VStack {
                Text("Home Screen")
                Button("Go to Next Screen") {
                    presenter.router.navigateToNextScreen()
                }
                Button("Go Back") {
                    presenter.router.navigateBack()
                }
                Button("Go to Root") {
                    presenter.router.navigateToRoot()
                }
            }
            .navigationTitle("Home")
            .background(
                NavigationLink(
                    destination: presenter.router.navigationPath.last,
                    isActive: Binding(
                        get: { !presenter.router.navigationPath.isEmpty },
                        set: { _ in }
                    ),
                    label: { EmptyView() }
                )
            )
        }
    }
}
