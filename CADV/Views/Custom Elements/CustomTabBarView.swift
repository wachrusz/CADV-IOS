//
//  CustomTabBar.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.12.2024.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                selectedTab = 0
            }) {
                VStack(spacing: 5) {
                    Image("TabBarIconMainActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .opacity(selectedTab == 0 ? 1 : 0.5)
                .animation(.easeInOut, value: selectedTab == 0 ? 1 : 0.5)
            }
            
            Button(action: {
                selectedTab = 1
            }) {
                VStack(spacing: 5) {
                    Image("TabBarIconTrackerActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .opacity(selectedTab == 1 ? 1 : 0.5)
                .animation(.easeInOut, value: selectedTab == 1 ? 1 : 0.5)
            }
            
            Button(action: {
                selectedTab = 2
            }) {
                VStack(spacing: 5) {
                    Image("TabBarIconSettingsActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .opacity(selectedTab == 2 ? 1 : 0.5)
                .animation(.easeInOut, value: selectedTab == 2 ? 1 : 0.5)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .frame(height: 65)
        .background(.white)
        .overlay(
            Rectangle()
                .inset(by: 1)
                .stroke(.black, lineWidth: 0.01)
        )
        .navigationBarBackButtonHidden(true)
    }
}
