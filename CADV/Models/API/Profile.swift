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
    var ExpirationDate: String = ""
    
    enum CodingKeys: String, CodingKey{
        case Surname = "surname"
        case Name = "name"
        case UserID = "user_id"
        case AvatarURL = "avatar_url"
    }
}

func test_fetchProfileInfo() -> ProfileInfo{
    return ProfileInfo(Surname: "", Name: "", UserID: "", AvatarURL: "", ExpirationDate: "")
}

extension ProfileInfo {
    static func fromDictionary(_ dictionary: [String: Any]) -> ProfileInfo? {
        guard
            let surname = dictionary["surname"] as? String,
            let name = dictionary["name"] as? String,
            let userID = dictionary["user_id"] as? String,
            let avatarURL = dictionary["avatar_url"] as? String
        else {
            Logger.shared.log(.error, "Error parsing ProfileInfo dictionary. Missing required keys.")
            return nil
        }

        let expirationDate = dictionary["expiration_date"] as? String ?? ""
        
        return ProfileInfo(Surname: surname, Name: name, UserID: userID, AvatarURL: avatarURL, ExpirationDate: expirationDate)
    }
}

