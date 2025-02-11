//
//  TokenData.swift
//  CADV
//
//  Created by Misha Vakhrushin on 22.01.2025.
//

import Foundation

struct TokenData {
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresAt: Date
    var refreshTokenExpiresAt: Date
}

extension TokenData {
    init(from entity: TokenEntity) {
        self.accessToken = entity.accessToken
        self.refreshToken = entity.refreshToken
        self.accessTokenExpiresAt = entity.accessTokenExpiresAt
        self.refreshTokenExpiresAt = entity.refreshTokenExpiresAt
    }
}
