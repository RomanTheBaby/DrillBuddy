//
//  Drill.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-25.
//

import Foundation
import OSLog
import SwiftData

@Model
class Drill: Identifiable, Hashable, Equatable, CustomStringConvertible {
    
    // MARK: - SendableRepresentation
    
    struct SendableRepresentation: Codable, Hashable {
        var id: UUID
        var date: Date
        var sounds: [DrillEntry]
        var recordingURL: URL?
    }
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: UUID
    
    @Attribute(.unique)
    private(set) var date: Date
    private(set) var sounds: [DrillEntry]
    private(set) var recordingURL: URL?
    
    @Relationship(inverse: \DrillsSessionsContainer.drills) var container: DrillsSessionsContainer?
    
    @Transient
    var sendableRepresentation: SendableRepresentation {
        SendableRepresentation(
            id: id,
            date: date,
            sounds: sounds,
            recordingURL: recordingURL
        )
    }
    
    // MARK: CustomStringConvertible
    
    @Transient
    var description: String {
        "Drill(id: \(id), date: \(date), entries: \(sounds), recordingURL: \(recordingURL?.absoluteString ?? "NO_URL"))"
    }
    
    // MARK: - Init
    
    init(id: UUID = UUID(), date: Date = Date(), sounds: [DrillEntry], recordingURL: URL? = nil) {
        self.id = id
        self.date = date
        self.sounds = sounds
        self.recordingURL = recordingURL
    }
    
    convenience init(sendableRepresentation: SendableRepresentation) {
        self.init(
            id: sendableRepresentation.id,
            date: sendableRepresentation.date,
            sounds: sendableRepresentation.sounds,
            recordingURL: sendableRepresentation.recordingURL
        )
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(sounds)
        hasher.combine(recordingURL)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Drill, rhs: Drill) -> Bool {
        lhs.id == rhs.id
            && lhs.date == rhs.date
            && lhs.sounds == rhs.sounds
            && lhs.recordingURL == rhs.recordingURL
    }
}
