//
//  AnalyticsPageGoal.swift
//  CADV
//
//  Created by Misha Vakhrushin on 01.10.2024.
//

import Foundation

struct Goal: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let CurrentState: Double
    let StartDate: String
    let EndDate: String
    let GoalName: String
    let ID: Int
    let Need: Double
    let UserID: String
    let Currency: String

    enum CodingKeys: String, CodingKey {
        case CurrentState = "current_state"
        case GoalName = "goal"
        case ID = "id"
        case Need = "need"
        case UserID = "user_id"
        case StartDate = "start_date"
        case EndDate = "end_date"
        case Currency = "currency"
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "current_state": self.CurrentState,
            "start_date": self.StartDate,
            "end_date": self.EndDate,
            "goal": self.GoalName,
            "id": self.ID,
            "need": self.Need,
            "user_id": self.UserID,
            "currency": self.Currency
        ]
    }
}
/*
func generateTestGoal() -> [Goal] {
    var array: [Goal] = []
    for _ in 1...100{
        let randomNeed = Double.random(in: 1000...10000)
        let randomGoal = UUID().uuidString
        let randomLength = Int.random(in: 1...60)
        let randomID = UUID().uuidString
        let randomUserID = UUID().uuidString
        
        array.append(Goal(
            CurrentState: 0,
            GoalName: randomGoal,
            ID: "",
            Need: randomNeed,
            UserID: "",
            StartDate: Date(),
            EndDate: Date().addingTimeInterval(TimeInterval(randomLength))
        ))
    }

    return array
}
*/
