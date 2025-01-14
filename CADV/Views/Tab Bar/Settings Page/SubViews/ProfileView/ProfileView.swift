//
//  ProfileView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.10.2024.
//

import SwiftUI

struct ProfileSection: View {
    @Binding var urlElements: URLElements?
    @Binding var profileInfo: ProfileInfo
    var body: some View {
        NavigationLink(destination: ProfileSettingsView(
            currentData: $profileInfo,
            urlElements: $urlElements
        )) {
            HStack {
                AsyncImage(
                    url: URL(string: profileInfo.AvatarURL)
                )
                .frame(width: 45, height: 45)
                .background(Color.gray)
                .clipShape(Circle())
                .padding()
                VStack(alignment: .leading, spacing: 5) {
                    CustomText(
                        text: "Настроить профиль",
                        font: Font.custom("Gilroy", size: 16).weight(.semibold),
                        color: Color("fg")
                    )

                    CustomText(
                        text: "Подписка до \(profileInfo.ExpirationDate)",
                        font: Font.custom("Gilroy", size: 16).weight(.semibold),
                        color: Color("sc2")
                    )
                }
                Spacer()
            }
            .frame(maxWidth: 300, maxHeight: 75)
            .background(Color("bg1"))
            .cornerRadius(15)
            .padding()
        }
    }
}
