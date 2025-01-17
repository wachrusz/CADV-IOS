//
//  BankAcoountList.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct BankAccountList: View {
    var bankAccounts: BankAccounts
    
    var body: some View {
        HStack {
            Image(bankAccounts.Group?.rawValue ?? "")
                .resizable()
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(bankAccounts.Array.first?.name ?? "Ваши Счета")
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                ForEach(bankAccounts.Array) { account in
                    ForEach(account.subAccounts){ subAccount in
                        Text(subAccount.name)
                            .font(.custom("Gilroy", size: 12).weight(.semibold))
                            .foregroundColor(Color.black.opacity(0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(formattedTotalAmount(amount: bankAccounts.TotalAmount))
                    .font(.custom("Gilroy", size: 14).weight(.semibold))
                    .foregroundColor(Color.black)
                ForEach(bankAccounts.Array) { account in
                    ForEach(account.subAccounts){ subAccount in
                        Text("\(currencyCodeToSymbol(code: subAccount.currency.rawValue)) \(formattedTotalAmount(amount: subAccount.totalAmount))")
                            .font(.custom("Gilroy", size: 12).weight(.semibold))
                            .foregroundColor(Color.black.opacity(0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onAppear(){
                Logger.shared.log(.info, bankAccounts)
            }
        }
        .frame(maxHeight: 100)
        .cornerRadius(10)
    }
}
