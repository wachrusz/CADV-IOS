//
//  BankAcoountList.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct BankAccountList: View {
    var bankAccount: BankAccount
    
    var body: some View{
        HStack{
            Image(bankAccount.name)
                .resizable()
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 5){
                Text(bankAccount.name)
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                ForEach(bankAccount.subAccounts){subAccount in
                    Text(subAccount.name)
                        .font(.custom("Gilroy", size: 12).weight(.semibold))
                        .foregroundColor(Color.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 5){
                Text(formattedTotalAmount(amount: bankAccount.totalAmount))
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                ForEach(bankAccount.subAccounts){subAccount in
                    Text("\(currencyCodeToSymbol(code: subAccount.currency.rawValue)) \(formattedTotalAmount(amount: subAccount.totalAmount))")
                        .font(.custom("Gilroy", size: 12).weight(.semibold))
                        .foregroundColor(Color.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxHeight: 100)
        .cornerRadius(10)
    }
}
