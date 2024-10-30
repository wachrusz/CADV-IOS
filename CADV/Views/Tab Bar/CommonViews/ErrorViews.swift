//
//  ErrorsView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 29.10.2024.
//
import SwiftUI

struct ErrorScreenView: View{
    var image: String
    var text: String
    
    var body: some View{
        VStack{
            Image(image)
                .resizable()
                .frame(maxWidth: 100, maxHeight: 100)
            Text(text)
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
