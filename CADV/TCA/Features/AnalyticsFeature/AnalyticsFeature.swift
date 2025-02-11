//
//  AnalyticsFeature.swift
//  CADV
//
//  Created by Misha Vakhrushin on 09.02.2025.
//
/*
import ComposableArchitecture

@Reducer
struct AnalyticsFeature {
    @Dependency(\.analyticsClient) var analyticsClient
    
    @ObservableState
    struct AnalyticsState {
        var isAnalyticsLoaded: Bool = false
        var categorizedTransactions: [CategorizedTransaction] = []
        var goals: [Goal] = []
        var profile: ProfileInfo?
    }

    enum AnalyticsAction {
        case loadAnalyticsPage
        case fetchData
        case fetchProfileData
        case fetchTracker
        case fetchMain
        case fetchMore
        case updateTransactions([CategorizedTransaction])
        case updateGoals([Goal])
        case updateProfile(ProfileInfo)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadAnalyticsPage:
                state.isAnalyticsLoaded = true
                return .none

            case .fetchData:
                return .run { send in
                    await send(.fetchProfileData)
                    await send(.fetchMain)
                    await send(.fetchTracker)
                    await send(.fetchMore)
                }

            case .fetchProfileData:
                return .run { send in
                    let profile = await analyticsClient.fetchProfile()
                    await send(.updateProfile(profile))
                }

            case .fetchTracker:
                return .run { send in
                    let goals = await analyticsClient.fetchTracker()
                    await send(.updateGoals(goals))
                }

            case .fetchMain:
                return .run { send in
                    let transactions = await analyticsClient.fetchMain()
                    await send(.updateTransactions(transactions))
                }

            case .fetchMore:
                return .run { send in
                    await analyticsClient.fetchMore()
                }

            case let .updateTransactions(transactions):
                state.categorizedTransactions = transactions
                return .none

            case let .updateGoals(goals):
                state.goals = goals
                return .none

            case let .updateProfile(profile):
                state.profile = profile
                return .none
            }
        }
    }
}
*/
