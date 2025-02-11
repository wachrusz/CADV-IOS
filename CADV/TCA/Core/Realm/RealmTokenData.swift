//
//  RealmTokenData.swift
//  CADV
//
//  Created by Misha Vakhrushin on 22.01.2025.
//

import RealmSwift

class TokenEntity: Object {
    @Persisted(primaryKey: true) var deviceID: String
    @Persisted var accessToken: String
    @Persisted var refreshToken: String
    @Persisted var accessTokenExpiresAt: Date
    @Persisted var refreshTokenExpiresAt: Date
}
