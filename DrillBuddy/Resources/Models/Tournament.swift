//
//  Tournament.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-30.
//

import Foundation

struct Tournament: Identifiable, Codable {
    
    struct Requirements: Codable {
        var gunType: GunType = .any
        var gunActionType: GunActionType = .any
        var maxTime: TimeInterval
    }
    
    var id: String
    
    var startDate: Date
    var endDate: Date
    
    var title: String
    var description: String
    var leaderboardID: String
    var requirements: Requirements
    
    var recordingConfiguration: DrillRecordingConfiguration = .default
    
    var maxShotsCount: Int {
        recordingConfiguration.maxShots
    }
    
}

// MARK: - Leaderboard

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
