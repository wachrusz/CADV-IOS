//
//  Logger.swift
//  CADV
//
//  Created by Misha Vakhrushin on 15.01.2025.
//


import Foundation

enum LogLevel: String {
    case error = "❌ ERROR"
    case warning = "⚠️ WARNING"
    case info = "ℹ️ INFO"
}

class Logger {
    static let shared = Logger()
    
    private init() {}
    
    func log(_ level: LogLevel, _ message: Any, file: String = #file, line: Int = #line) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[CADVApp] \(timestamp) [\(level.rawValue)] \(message) (File: \(fileName), Line: \(line))"
        
        print(logMessage)
    }
}
