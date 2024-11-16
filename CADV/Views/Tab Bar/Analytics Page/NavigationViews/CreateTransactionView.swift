//
//  CreateTransactionView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 14.11.2024.
//

import SwiftUI

struct CreateTransactionView: View{
    var body: some View{
        VStack{
            ActionDissmisButtons(
                action: createTransaction,
                actionTitle: "Создать"
            )
        }
    }
    
    private func createTransaction(){
        
    }
}
