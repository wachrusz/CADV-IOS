//
//  SplashScreen.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.11.2024.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var isExpanded = false
    @State private var showAppIcon = false

    var body: some View {
        if isActive {
            StartView()
        } else {
            ZStack {
                if showAppIcon {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .transition(.blurReplace())
                        .cornerRadius(20)
                } else {
                    ZStack() {
                        Image("TabBarIconMainActive")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .offset(x: isExpanded ? -120 : 0)
                        Image("TabBarIconTrackerActive")
                            .resizable()
                            .frame(width: isExpanded ? 50 : 100, height: isExpanded ? 50 : 100)
                        Image("TabBarIconSettingsActive")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .offset(x: isExpanded ? 120 : 0)
                    }
                    .transition(.opacity)
                    .opacity(isExpanded ? 1 : 0)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.25)) {
                    isExpanded = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        isExpanded = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        showAppIcon = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        isActive = true
                    }
                }
            }
        }
    }
}
