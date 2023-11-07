//
//  TournamentEntry.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-05.
//

import Foundation
import OSLog
import SwiftData

@Model
class TournamentEntry: Encodable, CustomStringConvertible {
    
    // MARK: - CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case sounds
        case recordingURL
    }
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var tournamentId: String
    
    @Attribute(.unique)
    private(set) var date: Date
    private(set) var sounds: [DrillEntry]
    private(set) var recordingURL: URL
    
    // MARK: CustomStringConvertible
    
    @Transient
    var description: String {
        "TournamentEntry(tournamentId: \(tournamentId), date: \(date)), sounds: \(sounds), recordingURL: \(recordingURL))"
    }
    
    
    // MARK: - Init
    
    init(
        tournamentId: String,
        date: Date,
        sounds: [DrillEntry],
        recordingURL: URL
    ) {
        self.tournamentId = tournamentId
        self.date = date
        self.sounds = sounds
        self.recordingURL = recordingURL
    }
    
    // MARK: - Encodable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(sounds, forKey: .date)
        try container.encode(recordingURL, forKey: .date)
    }
    
}
