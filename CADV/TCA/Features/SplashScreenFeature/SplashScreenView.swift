//
//  SplashScreen.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.11.2024.
//

import SwiftUI
import ComposableArchitecture

struct SplashScreenViewTCA: View {
    let store: StoreOf<SplashScreenFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.isActive{
                if viewStore.logged {
                    LocalAuthViewTCA(store: Store(
                        initialState: LocalAuthFeature.State(),
                        reducer: {
                            LocalAuthFeature()
                        }
                    )
                )
                }else{
                    StartViewTCA(
                        store: Store(
                            initialState: StartViewFeature.State(),
                            reducer: {
                                StartViewFeature()
                            }
                        )
                    )
                }
            } else {
                ZStack {
                    if viewStore.showAppIcon {
                        Image("appIcon")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .transition(.blurReplace())
                            .cornerRadius(20)
                    } else {
                        ZStack {
                            Image("TabBarIconMainActive")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .offset(x: viewStore.isExpanded ? -120 : 0)
                            Image("TabBarIconTrackerActive")
                                .resizable()
                                .frame(width: viewStore.isExpanded ? 50 : 100, height: viewStore.isExpanded ? 50 : 100)
                            Image("TabBarIconSettingsActive")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .offset(x: viewStore.isExpanded ? 120 : 0)
                        }
                        .transition(.opacity)
                        .opacity(viewStore.isExpanded ? 1 : 0)
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}
