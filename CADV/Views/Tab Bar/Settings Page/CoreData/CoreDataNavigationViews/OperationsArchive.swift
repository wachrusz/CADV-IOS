//
//  OperationsArchive.swift
//  CADV
//
//  Created by Misha Vakhrushin on 07.11.2024.
//

import SwiftUI

struct OperationsArchiveView: View {
    var operationsArchive: [CategorizedTransaction] = []
    
    var body: some View {
        VStack {
            CommonHeader(
                image: "WasteBasket",
                headerText: "Архив операций",
                subHeaderText: "Исходные операции объединения"
            )
            if operationsArchive.isEmpty {
                Text("Здесь появятся исходные данные объединения операций")
            }else{
                ForEach(operationsArchive, id: \.self){ operation in TransactionElement(transaction: operation)
                }
            }
        }
    }
}
