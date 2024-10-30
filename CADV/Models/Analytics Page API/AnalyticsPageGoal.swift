//
//  AnalyticsPageGoal.swift
//  CADV
//
//  Created by Misha Vakhrushin on 01.10.2024.
//

import Foundation

struct Goal: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let CurrentState: Int
    let GoalName: String
    let ID: String
    let Need: Double
    let UserID: String

    enum CodingKeys: String, CodingKey {
        case CurrentState = "current_state"
        case GoalName = "goal"
        case ID = "id"
        case Need = "need"
        case UserID = "user_id"
    }
    
}

func generateTestGoal() -> [Goal] {
    var array: [Goal] = []
    for _ in 1...100{
        let randomNeed = Double.random(in: 1000...10000)
        let randomGoal = UUID().uuidString
        let randomLength = Int.random(in: 1...60)
        let randomID = UUID().uuidString
        let randomUserID = UUID().uuidString
        
        array.append(Goal(
            CurrentState: randomLength,
            GoalName: randomGoal,
            ID: randomID,
            Need: randomNeed,
            UserID: randomUserID
        ))
    }

    return array
}
