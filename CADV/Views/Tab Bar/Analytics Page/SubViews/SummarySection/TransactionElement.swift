//
//  TransactionElement.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct TransactionElement: View{
    var transaction: CategorizedTransaction
    
    var body: some View{
        HStack{
            Image("education")
                .resizable()
                .frame(width: 40,height: 40)
            VStack(alignment: .leading, spacing: 5){
                Text(transaction.name)
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                Text(transaction.category.displayName)
                    .font(.custom("Gilroy", size: 12).weight(.semibold))
                    .foregroundColor(Color.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            currencyAndAmountText(transaction: transaction)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func currencyAndAmountText(transaction: CategorizedTransaction) -> some View {
        HStack{
            Text(currencyCodeAndTypeToSymbol(type: transaction.type, code: transaction.currency.rawValue))
                .foregroundColor(transaction.type.rawValue == "Доходы" ? Color.green : Color.red)
            Text(formattedTotalAmount(amount: transaction.amount))
                .foregroundColor(Color.black)
        }
    }
}
