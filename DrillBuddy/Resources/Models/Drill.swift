//
//  Drill.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-25.
//

import Foundation
import SwiftData

@Model
class Drill: Identifiable, Hashable, Equatable, CustomStringConvertible {
    
    // MARK: - SendableRepresentation
    
    struct SendableRepresentation: Codable, Hashable {
        var id: UUID
        var date: Date
        var sounds: [DrillEntry]
        var notes: String
        var recordingConfiguration: DrillRecordingConfiguration
    }
    
    // MARK: - Properties
    
    @Attribute(.unique)
    private(set) var id: UUID
    
    @Attribute(.unique)
    private(set) var date: Date
    private(set) var sounds: [DrillEntry]
    
    private(set) var notes: String = ""
    
    @Relationship(inverse: \DrillsSessionsContainer.drills) var container: DrillsSessionsContainer?
    
    @Transient
    var sendableRepresentation: SendableRepresentation {
        SendableRepresentation(
            id: id,
            date: date,
            sounds: sounds,
            notes: notes,
            recordingConfiguration: recordingConfiguration
        )
    }
    
    @Transient
    var recordingURL: URL? {
        try? AudioRecordingPathGenerator.path(for: self, createMissingDirectories: false)
    }
    
    @Transient
    private(set) var recordingConfiguration: DrillRecordingConfiguration = .default
    
    private var recordingConfigurationData: Data
    
    // MARK: CustomStringConvertible
    
    @Transient
    var description: String {
        """
        Drill(
        id: \(id),
        date: \(date), 
        entries: \(sounds),
        recordingURL: \((try? AudioRecordingPathGenerator.path(for: self, createMissingDirectories: false))?.absoluteString ?? "no recording")
        )
        """
    }
    
    // MARK: - Init
    
    init(id: UUID = UUID(), date: Date = Date(), sounds: [DrillEntry], notes: String = "", recordingConfiguration: DrillRecordingConfiguration) {
        self.id = id
        self.date = date
        self.sounds = sounds
        self.notes = notes
        self.recordingConfiguration = recordingConfiguration
        self.recordingConfigurationData = try! JSONEncoder().encode(recordingConfiguration)
    }
    
    convenience init(sendableRepresentation: SendableRepresentation) {
        self.init(
            id: sendableRepresentation.id,
            date: sendableRepresentation.date,
            sounds: sendableRepresentation.sounds,
            notes: sendableRepresentation.notes,
            recordingConfiguration: sendableRepresentation.recordingConfiguration
        )
    }
    
    func updateNotes(newNotes: String) {
        notes = newNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(sounds)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Drill, rhs: Drill) -> Bool {
        lhs.id == rhs.id
            && lhs.date == rhs.date
            && lhs.sounds == rhs.sounds
    }
}
