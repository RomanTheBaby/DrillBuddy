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
    
    var id: UUID = UUID()
    
    var startDate: Date
    var endDate: Date
    
    var title: String
    var description: String
    var requirements: Requirements
    
    var recordingConfiguration: DrillRecordingConfiguration = .default
    
    var maxShotsCount: Int {
        recordingConfiguration.maxShots
    }
    
}

struct Leaderboard {
    struct Entry {
        var username: String
        var recordingData: Data
        var firstShotDelay: TimeInterval
        var shotsSplit: TimeInterval
        var totalTime: TimeInterval
    }
    
    var id: UUID
    var entries: [Entry]
    var tournamentID: UUID
}
