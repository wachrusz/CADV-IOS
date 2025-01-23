//
//  ContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 03.09.2024.
//

import SwiftUI

struct ContentView: View {
    @Binding var urlElements: URLElements?
    init(urlElements: Binding<URLElements?>) {
        self._urlElements = urlElements
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some View {
        StartView(urlElements: $urlElements)
    }
}
