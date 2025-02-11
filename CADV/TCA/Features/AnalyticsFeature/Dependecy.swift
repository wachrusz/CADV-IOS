//
//  Dependecy.swift
//  CADV
//
//  Created by Misha Vakhrushin on 09.02.2025.
//
/*
import Dependencies
import SwiftyJSON

struct AnalyticsClient {
    var fetchProfile: @Sendable () async -> ProfileInfo
    var fetchMain: @Sendable () async -> [CategorizedTransaction]
    var fetchTracker: @Sendable () async -> [Goal]
    var fetchMore: @Sendable () async -> Void
}

extension AnalyticsClient: DependencyKey {
    static let liveValue = AnalyticsClient(
        fetchProfile: {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile",
                method: "GET",
                needsAuthorization: true
            )
            let json = JSON(response)
            return ProfileInfo(json: json["profile"])
        },
        fetchMain: {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/analytics?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            let json = JSON(response)
            let analytics = json["analytics"]
            let transactionsArray = (analytics["income"].arrayValue + analytics["expense"].arrayValue + analytics["wealth_fund"].arrayValue)
            return transactionsArray.compactMap { CategorizedTransaction(json: $0) }
        },
        fetchTracker: {
            let response = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/tracker?limit=20&offset=0",
                method: "GET",
                needsAuthorization: true,
                needsCurrency: true
            )
            let json = JSON(response)
            return json["tracker"]["goal"].arrayValue.compactMap { Goal(json: $0) }
        },
        fetchMore: {
            _ = try await URLElements.shared.fetchData(
                endpoint: "v1/profile/more",
                method: "GET",
                needsAuthorization: true
            )
        }
    )
}

extension DependencyValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}
*/
