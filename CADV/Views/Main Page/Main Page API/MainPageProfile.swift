//
//  MainPageProfile.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import Foundation

struct ProfileInfo: Codable{
    let Surname: String
    let Name: String
    let UserID: String
    let AvatarURL: String
    
    enum CodingKeys: String, CodingKey{
        case Surname = "surname"
        case Name = "name"
        case UserID = "user_id"
        case AvatarURL = "avatar_url"
    }
    
    static func GetProfileInfo() -> ProfileInfo{
        return ProfileInfo(Surname: "Wachruszyn", Name: "Michał", UserID: "1", AvatarURL: "https://prikol.com/1")
    }
}
