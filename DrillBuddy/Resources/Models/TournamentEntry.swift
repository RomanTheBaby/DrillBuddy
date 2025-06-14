//
//  TournamentEntry.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-05.
//

import Foundation
import SwiftData

@Model
class TournamentEntry: CustomStringConvertible {
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var tournamentId: String
    
    private(set) var userId: String
    
    @Attribute(.unique)
    private(set) var date: Date
    private(set) var sounds: [DrillEntry]
    
    @Transient
    var recordingURL: URL? {
        try? AudioRecordingPathGenerator.pathForRecording(at: date, createMissingDirectories: false)
    }
    
    // MARK: CustomStringConvertible
    
    @Transient
    var description: String {
        "TournamentEntry(tournamentId: \(tournamentId), date: \(date)), sounds: \(sounds), recordingURL: \(recordingURL?.absoluteString ?? "no recording"))"
    }
    
    // MARK: - Init
    
    init(
        tournamentId: String,
        userId: String,
        date: Date,
        sounds: [DrillEntry]
    ) {
        self.tournamentId = tournamentId
        self.userId = userId
        self.date = date
        self.sounds = sounds
    }
    
}
