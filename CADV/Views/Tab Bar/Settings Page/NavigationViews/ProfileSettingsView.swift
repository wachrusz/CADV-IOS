//
//  ProfileSettings.swift
//  CADV
//
//  Created by Misha Vakhrushin on 28.10.2024.
//

import SwiftUI

struct ProfileSettingsView: View{
    @Environment(\.presentationMode) var presentationMode
    @Binding public var currentData: ProfileInfo
    @State private var newData: ProfileInfo = ProfileInfo(Surname: "", Name: "", UserID: "", AvatarURL: "", ExpirationDate: "")
    
    var body: some View{
        VStack{
            HStack(alignment: .center, spacing: 20){
                AsyncImage(url: URL(string: currentData.AvatarURL))
                    .frame(width: 45, height: 45)
                    .background(Color.gray)
                    .clipShape(Circle())
                Text("Сменить изображение")
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: 300, maxHeight: 75)
            .padding(.leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .onTapGesture {
                //TODO: realise
            }
            
            VStack{
                HStack(spacing: 20) {
                    TextField("", text: $newData.Name, prompt: Text("Имя").foregroundStyle(.black))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundStyle(.black)
                    
                    TextField("", text: $newData.Surname, prompt: Text("Фамилия").foregroundStyle(.black))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundStyle(.black)
                }
                .padding(.horizontal)
                
                ActionDissmisButtons(
                    action: saveChanges,
                    actionTitle: "Сохранить",
                    fontName: "Inter",
                    fontSize: 16
                )
            }
        }
        .onAppear {
            self.newData = ProfileInfo(
                       Surname: currentData.Surname,
                       Name: currentData.Name,
                       UserID: currentData.UserID,
                       AvatarURL: currentData.AvatarURL,
                       ExpirationDate: currentData.ExpirationDate
            )
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.white)
    }
    private func saveChanges() {
        // TODO: realise
        presentationMode.wrappedValue.dismiss()
    }
}

