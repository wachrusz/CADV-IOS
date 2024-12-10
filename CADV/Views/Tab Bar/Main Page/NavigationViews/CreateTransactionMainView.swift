//
//  CreateTransactionView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 18.11.2024.
//

import SwiftUI

struct CreateTransactionMainView: View {
    var categoryName: String
    
    var body: some View {
        VStack{
            CustomText(
                text: categoryName, font: Font.custom("Gilroy", size: 14).weight(.semibold), color: Color("fg"))
        }
    }
}
