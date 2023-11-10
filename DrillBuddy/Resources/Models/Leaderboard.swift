//
//  Leaderboard.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-06.
//

import Foundation

struct Leaderboard: Codable, Identifiable {
    struct Entry: Codable, Identifiable, Hashable {
        
        var id: String {
            userId
        }
        
        var userId: String
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
    
    func containsEntry(from user: UserInfo) -> Bool {
        entries.contains(where: { entry in
            entry.userId == user.id
        })
    }
}
