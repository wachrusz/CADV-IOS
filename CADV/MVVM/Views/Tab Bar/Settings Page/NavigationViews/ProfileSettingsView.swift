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
    
    @State private var showNameFieldError: Bool = false
    @State private var showSurnameFieldError: Bool = false
    @State private var isNameFieldFine: Bool = false
    @State private var isSurnameFieldFine: Bool = false
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View{
        ZStack{
            VStack(spacing: 20){
                CustomText(
                    text: "Настройка профиля",
                    font: Font.custom("Gilroy", size: 16).weight(.semibold),
                    color: Color("fg")
                )
                
                HStack{
                    AsyncImage(
                        url: URL(string: currentData.AvatarURL)
                    )
                    .frame(width: 45, height: 45)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .padding(.horizontal)
                    
                    CustomText(
                        text: "Сменить изображение",
                        font: Font.custom("Gilroy", size: 14).weight(.semibold),
                        color: Color("fg")
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 65)
                .background(Color("bg1"))
                .cornerRadius(15)
                .padding(.horizontal)
                .onTapGesture {
                    updateProfileImage()
                }
                
                HStack{
                    CustomTextField(
                        input: $newData.Name,
                        text: (currentData.Name != "" ? currentData.Name : "Имя"),
                        showTextFieldError: $showNameFieldError,
                        isFine: $isNameFieldFine
                    )
                    
                    CustomTextField(
                        input: $newData.Surname,
                        text: (currentData.Surname != "" ? currentData.Surname : "Фамилия"),
                        showTextFieldError: $showSurnameFieldError,
                        isFine: $isSurnameFieldFine
                    )
                }
                .padding(.horizontal)
                
                ActionDissmisButtons(
                    action: updateName,
                    actionTitle: "Сохранить"
                )
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
        .hideBackButton()
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
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/name",
                method: "PUT",
                parameters: parameters,
                needsAuthorization: true
            )
            switch response["status_code"] as? Int{
            case 200:
                presentationMode.wrappedValue.dismiss()
            default:
                errorMessage = "Something went wrong"
            }
        }
        catch let error{
            Logger.shared.log(.error, "\(error)")
        }
    }
}

