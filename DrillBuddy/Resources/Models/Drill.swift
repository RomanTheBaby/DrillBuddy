//
//  Drill.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-25.
//

import Foundation
import SwiftData

@Model
class Drill: Identifiable, Hashable, Equatable {
    
    // MARK: - SendableRepresentation
    
    struct SendableRepresentation: Codable {
        var id: UUID = UUID()
        var date: Date
        var sounds: [String]
        var recordingURL: URL?
    }
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: UUID
    
    @Attribute(.unique)
    private(set) var date: Date
    private(set) var sounds: [String]
    private(set) var recordingURL: URL?
    
    @Transient
    var sendableRepresentation: SendableRepresentation {
        SendableRepresentation(id: id, date: date, sounds: sounds, recordingURL: recordingURL)
    }
    
    // MARK: - Init
    
    init(id: UUID = UUID(), date: Date = Date(), sounds: [String], recordingURL: URL? = nil) {
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
