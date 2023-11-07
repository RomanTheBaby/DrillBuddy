//
//  Leaderboard.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-06.
//

import Foundation

struct Leaderboard: Codable {
    struct Entry: Codable {
        var username: String
        var recordingDate: Date
        var recordingData: Data
        var firstShotDelay: TimeInterval
        var shotsSplit: TimeInterval
        var totalTime: TimeInterval
    }
    
    var id: String
    var entries: [Entry]
    var tournamentID: String
}
