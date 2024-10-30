//
//  CommonSections.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI

struct UserProfileSection: View{
    @Binding var profile: ProfileInfo
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ProfileImageAndInfo(profile: $profile)
            
            Spacer()
            
            Text(Date().monthDayString())
                .font(.custom("Inter", size: 14).weight(.semibold))
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 3))
        }
        .frame(maxHeight: 45)
        .padding(.horizontal)
    }

}

struct ProfileImageAndInfo: View{
    @Binding var profile: ProfileInfo
    
    var body: some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: profile.AvatarURL))
                .aspectRatio(contentMode: .fill)
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .foregroundColor(.black)
            
            VStack(alignment: .leading) {
                Text("\(profile.Surname)\n\(profile.Name)")
                    .font(.custom("Gilroy", size: 14).weight(.bold))
                    .foregroundColor(.black)
            }.frame(maxWidth: .infinity)
        }
        .frame(height: 45)
    }
}

//Balance
struct TotalAmountView: View{
    var text: String
    @FetchRequest(
            entity: CurrencyEntity.entity(),
            sortDescriptors: [],
            animation: .default
    ) private var currencies: FetchedResults<CurrencyEntity>
    @State private var selectedCurrency: String = "RUB"

    
    var body: some View {
        HStack(spacing: 0) {
            Text(selectedCurrency)
                .font(.custom("Inter", size: 36).weight(.semibold))
                .foregroundColor(Color.gray)
            Text(text)
                .font(.custom("Inter", size: 45).weight(.bold))
                .foregroundColor(.black)
        }
        .frame(height: 85)
        .padding(.horizontal)
        .onAppear {
            if let firstCurrency = currencies.first, let currencyCode = firstCurrency.currency {
                selectedCurrency = currencyCode
            }
        }
    }
    
}
