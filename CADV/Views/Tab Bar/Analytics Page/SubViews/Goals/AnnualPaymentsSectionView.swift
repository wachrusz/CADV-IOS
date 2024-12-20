//
//  AnnualPaymentsSection.swift
//  CADV
//
//  Created by Misha Vakhrushin on 30.10.2024.
//

import SwiftUI

struct annualPaymentsSection: View{
    @Binding var annualPayments: [AnnualPayment]
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                CustomText(
                    text: "Ежемесячные платежи",
                    font: Font.custom("Gilroy", size: 16).weight(.semibold),
                    color: Color("fg"))
                
                CustomText(
                    text: "\(countCompleted(array: annualPayments))/\(annualPayments.count)",
                    font: Font.custom("Inter", size: 12).weight(.semibold),
                    color: Color("bg1")
                )
                .tracking(1)
            }
            switch annualPayments.count {
            case 0:
                VStack{
                    Spacer()
                    CustomText(
                        text: "Информация о ежемесячных отчислениях для постоянного прогресса в достижении Ваших целей",
                        font: Font.custom("Inter", size: 12).weight(.semibold),
                        color: Color("sc2")
                    )
                    Spacer()
                }
            default:
                TabView {
                    ForEach(0..<getNumberOfPages(itemsArray: annualPayments), id: \.self) { pageIndex in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                ForEach(getPageItems(items: annualPayments, pageIndex: pageIndex), id: \.ID) { payment in
                                    annualPaymentsItem(title: payment.name, totalAmount:  payment.amount, color: .orange, paidAmount: payment.paidAmount)
                                        .padding()
                                }
                            }
                            .padding()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(idealHeight: 500)
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }
    private func getPageItems(items: [AnnualPayment], pageIndex: Int) -> [AnnualPayment] {
        let startIndex = pageIndex * 20
        let endIndex = min(startIndex + 20, items.count)
        return Array(items[startIndex..<endIndex])
    }
}
