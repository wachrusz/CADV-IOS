//
//  AppView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    /*
     IDK, if we got shared storage we gotta make all Features' States & Actions
     conformable to be shared in AppFeature storage.
     */
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            OnboardingView(store:
                            store.scope(
                                state: \.onboardingState,
                                action: \.onboardingAction
                            )
            )
            .onAppear(){
                Logger.shared.log(.warning, URLElements.shared.tokenData)
            }
        }
    }
}
