//
//  TabBar.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Settings Screen")
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.white)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 10) {
            // Main tab button
            Button(action: {
                selectedTab = 0
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .background(selectedTab == 0 ? Color.gray.opacity(0.2) : .white)
            }
            
            // Analytics tab button
            Button(action: {
                selectedTab = 1
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "chart.bar.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .background(selectedTab == 1 ? Color.gray.opacity(0.2) : .white)
            }
            
            // Settings tab button
            Button(action: {
                selectedTab = 2
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
                .background(selectedTab == 2 ? Color.gray.opacity(0.2) : .white)
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

struct TabBarContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                switch selectedTab {
                case 0:
                    MainPageView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .navigationBarBackButtonHidden(true)
                case 1:
                    AnalyticsPageView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case 2:
                    SettingsView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                default:
                    MainPageView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }
}

struct TabBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarContentView()
    }
}
