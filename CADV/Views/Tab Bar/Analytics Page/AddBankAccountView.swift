//
//  AddBankAccountView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 22.10.2024.
//

import SwiftUI


struct AddBankAccountView: View{
    var body: some View{
        VStack{
            Image("wrench")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 100)
            Text("Извините, этого пока нет :(")
                .font(Font.custom("Inter", size: 14).weight(.semibold))
                .foregroundColor(.black)
                .cornerRadius(10)
                .frame(alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading)
        .background(.white)
        .edgesIgnoringSafeArea(.bottom)
        .hideBackButton()
    }
}
