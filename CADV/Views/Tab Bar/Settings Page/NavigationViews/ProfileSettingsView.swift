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
    @Binding var tokenData: TokenData
    @State private var newData: ProfileInfo = ProfileInfo(Surname: "", Name: "", UserID: "", AvatarURL: "", ExpirationDate: "")
    
    @State private var showNameFieldError: Bool = false
    @State private var showSurnameFieldError: Bool = false
    @State private var isNameFieldFine: Bool = false
    @State private var isSurnameFieldFine: Bool = false
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View{
        VStack{
            CustomText(
                text: "Настройка профиля",
                font: Font.custom("Gilroy", size: 16).weight(.semibold),
                color: Color("fg")
            )
            .padding(.vertical)
            
            HStack(alignment: .center, spacing: 20){
                AsyncImage(url: URL(string: currentData.AvatarURL))
                    .frame(width: 45, height: 45)
                    .background(Color.gray)
                    .clipShape(Circle())
                CustomText(
                    text: "Сменить изображение",
                    font: Font.custom("Gilroy", size: 14).weight(.semibold),
                    color: Color("fg")
                )
            }
            .padding(.vertical)
            .background(Color("bg1"))
            .cornerRadius(15)
            .onTapGesture {
                //TODO: realise
            }
            
            VStack{
                HStack(spacing: 20) {
                    CustomTextField(
                        input: $newData.Name,
                        text: "Имя",
                        showTextFieldError: $showNameFieldError,
                        isFine: $isNameFieldFine
                    )
                    
                    CustomTextField(
                        input: $newData.Surname,
                        text: "Фамилия",
                        showTextFieldError: $showSurnameFieldError,
                        isFine: $isSurnameFieldFine
                    )
                }
                .padding(.horizontal)
                
                ActionDissmisButtons(
                    action: updateName,
                    actionTitle: "Сохранить"
                )
                .padding()
                
                Spacer()
            }
            ErrorPopUp(
                showErrorPopup: $showErrorPopup,
                errorMessage: errorMessage
            )
        }
        .onAppear {
            self.newData = ProfileInfo(
                       Surname: "",
                       Name: "",
                       UserID: currentData.UserID,
                       AvatarURL: currentData.AvatarURL,
                       ExpirationDate: currentData.ExpirationDate
            )
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.white)
    }
    
    private func updateProfileImage() {
        
    }
    
    private func updateName() async{
        let name = newData.Name
        let surname = newData.Surname
        
        let parameters = [
            "name": name,
            "surname": surname
        ]
        do{
            let response = try await abstractFetchData(
                endpoint: "v1/profile/name",
                method: "PUT",
                parameters: parameters,
                headers: [
                    "accept" : "application/json",
                    "Content-Type": "application/json",
                    "Authorization" : tokenData.accessToken
                ]
            )
            switch response["status_code"] as? Int{
            case 200:
                presentationMode.wrappedValue.dismiss()
            default:
                errorMessage = "Something went wrong"
            }
        }
        catch let error{
            print(error)
        }
    }
}

