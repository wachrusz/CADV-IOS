//
//  ProfileView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI

struct profileSection: View{
    @Binding var isSheetPresented: Bool
    @Binding var selectedScreen: String?
    var imageURL: String = ""
    var expirationDate: String = "5 nojabrja"
    var body: some View{
        HStack(alignment: .center, spacing: 20){
            AsyncImage(url: URL(string: imageURL))
                .frame(width: 45, height: 45)
                .background(Color.gray)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 5){
                Text("Настроить профиль")
                    .foregroundStyle(.black)
                Text("Подписка до \(expirationDate)")
                    .foregroundStyle(.black.opacity(0.5))
            }
        }
        .frame(maxWidth: 300, maxHeight: 75)
        .padding(.leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .onTapGesture {
            handleButtonTap("Настроить профиль")
        }
    }
    func handleButtonTap(_ screen: String) {
        selectedScreen = screen
        isSheetPresented = true
    }
}
