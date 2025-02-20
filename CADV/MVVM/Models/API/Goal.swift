//
//  AnalyticsPageGoal.swift
//  CADV
//
//  Created by Misha Vakhrushin on 01.10.2024.
//

import Foundation
import SwiftyJSON

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
    
    init(currentState: Double,
         goalName: String,
         need: Double,
         userID: String,
         startDate: String,
         endDate: String,
         currency: String,
         id: Int
    ) {
        self.CurrentState = currentState
        self.GoalName = goalName
        self.ID = id
        self.Need = need
        self.UserID = userID
        self.StartDate = startDate
        self.EndDate = endDate
        self.Currency = currency
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
    
    init(json: JSON){
        self.ID = json["id"].int ?? 0
        self.EndDate = json["end_date"].string ?? ""
        self.GoalName = json["goal"].string ?? ""
        self.Need = json["need"].double ?? 0
        self.StartDate = json["start_date"].string ?? ""
        self.CurrentState = json["current_state"].double ?? 0
        self.UserID = json["user_id"].string ?? ""
        self.Currency = json["currency"].string ?? ""
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
