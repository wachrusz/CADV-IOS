//
//  MainPageProfile.swift
//  CADV
//
//  Created by Misha Vakhrushin on 24.09.2024.
//

import Foundation

struct ProfileInfo: Codable{
    var Surname: String
    var Name: String
    let UserID: String
    var AvatarURL: String
    var ExpirationDate: String
    
    enum CodingKeys: String, CodingKey{
        case Surname = "surname"
        case Name = "name"
        case UserID = "user_id"
        case AvatarURL = "avatar_url"
        case ExpirationDate = "expiration_date"
    }
    
    static func GetProfileInfo() -> ProfileInfo{
        return ProfileInfo(Surname: "Wachruszyn", Name: "Michał", UserID: "1", AvatarURL: "https://prikol.com/1", ExpirationDate: "5 nojabrja")
    }
}

func test_fetchProfileInfo() -> ProfileInfo{
    return ProfileInfo(Surname: "Wachruszka", Name: "Miszka", UserID: "1", AvatarURL: "https://prikol.com/1", ExpirationDate: "5 nojabrja")
}
