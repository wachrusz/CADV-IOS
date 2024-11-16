//
//  BankAccountCategorySelectionView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 14.11.2024.
//

import SwiftUI

struct BankAccountCategorySelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategory: BankAccountsGroup?
    
    var body: some View {
        VStack{
            List(BankAccountsGroup.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack(alignment: .center) {
                        Image(category.returnImageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                        CustomText(
                            text: category.rawValue,
                            font: Font.custom("Gilroy", size: 16).weight(.semibold),
                            color: Color("fg")
                        )
                        Spacer()
                    }
                    .padding(10)
                    .background(Color("bg1"))
                    .cornerRadius(15)
                }
            }
            ActionDissmisButtons(
                action: navigate,
                actionTitle: "Создать новую"
            )
        }
        .navigationTitle("Выберите категорию")
    }
    private func navigate() {
        
    }
}
