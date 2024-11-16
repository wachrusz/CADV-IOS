//
//  SupportRequestView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 07.11.2024.
//

import SwiftUI

struct SupportRequestView:View{
    @Environment(\.dismiss) var dismiss
    
    @State var email:String = ""
    @State var theme: String = ""
    @State var text: String = ""
    
    var body: some View{
        VStack(alignment: .leading){
            Text("Ответ придёт на почту:")
                .padding(.leading)
                .cornerRadius(15)
                .frame(maxHeight: 40)
            TextField(
                "example@gmail.com",
                text: $email
            )
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .frame(maxHeight: 40)
            Text("Тема обращения:")
                .padding(.leading)
                .cornerRadius(15)
                .frame(maxHeight: 40)
            TextField(
                "Тема",
                text: $theme
            )
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .frame(maxHeight: 40)
            Text("Текст обращения:")
                .padding(.leading)
                .cornerRadius(15)
                .frame(maxHeight: 40)
            
            
            //gotta fix dat
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.gray.opacity(0.2))
                .placeholder(when: text.isEmpty){
                    Text("Сюда поместится даже ооооооооооооооооо ооооооооооооооооооооооооооооооооооооооооочень большой текст")
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                .padding()
                .frame(maxHeight: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .animation(.easeInOut, value: text.count)
            
            
            ActionDissmisButtons(
                action: send,
                actionTitle: "Отправить"
            )
            Spacer()
        }
        .navigationTitle("Написать в поддержку")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .colorScheme(.light)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
    private func send(){
        do{
            dismiss()
        }
    }
}
