//
//  CommonSections.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI

struct CommonHeader: View{
    var image: String
    var headerText: String
    var subHeaderText: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20){
            Image(image)
                .frame(width: 45, height: 45)
            VStack(alignment: .leading, spacing: 5){
                Text(headerText)
                    .foregroundStyle(.black)
                Text(subHeaderText)
                    .foregroundStyle(.black.opacity(0.5))
            }
        }
        .frame(maxWidth: 300, maxHeight: 75)
        .padding(.leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct UserProfileSection: View{
    @Binding var profile: ProfileInfo
    let font: Font = .custom("Inter", size: 14).weight(.semibold)
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ProfileImageAndInfo(profile: $profile)
            
            Spacer()
            
            CustomText(
                text: Date().monthDayString(),
                font: font,
                color: Color("fg")
            )
            .padding()
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 3))
        }
        .frame(maxHeight: 45)
        .padding(.horizontal)
    }

}

struct ProfileImageAndInfo: View{
    @Binding var profile: ProfileInfo
    private let font: Font = Font.custom("Gilroy", size: 14).weight(.bold)
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            AsyncImage(url: URL(string: profile.AvatarURL))
                .aspectRatio(contentMode: .fill)
                .frame(width: 45, height: 45, alignment: .leading)
                .clipShape(Circle())
                .foregroundColor(.black)
            
            VStack() {
                CustomText(
                    text: "\(profile.Surname) \(profile.Name)",
                    font: font,
                    color: Color("fg")
                )
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 45)
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
            CustomText(
                text: currencyCodeToSymbol(code: selectedCurrency),
                font: .custom("Inter", size: 36).weight(.semibold),
                color: Color("sc1")
            )
            .padding(.bottom)
            CustomText(
                text: text,
                font: .custom("Inter", size: 45).weight(.bold),
                color: Color("fg")
            )
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
