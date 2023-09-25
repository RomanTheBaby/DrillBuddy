//
//  DrillsSessionsContainer.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import Foundation
import SwiftData

@Model
class DrillsSessionsContainer: Identifiable, Codable, Hashable {
    
    // MARK: - Properties
    
    @Transient
    var id: Date {
        date
    }
    
    @Transient
    var title: String {
        DateFormatter.drillSessionsContainer.string(from: date)
    }
    
    /// This date is at format of
    @Attribute(.unique) private(set) var date: Date
    private(set) var drills: [Drill]
    
    // MARK: - CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case date
        case drills
    }
    
    // MARK: - Init
    
    init(date: Date = Date(), drills: [Drill]) {
        self.date = date.containerFormatted
        self.drills = drills
    }
    
    // MARK: - Decodable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        drills = try container.decode([Drill].self, forKey: .drills)
    }
    
    // MARK: - Encodable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(drills, forKey: .drills)
    }
}

@Model
class Drill: Identifiable, Codable, Hashable {
    
    // MARK: - Properties
    
    @Attribute(.unique)
    var id: UUID = UUID()
    var sounds: [String]
    var recordingURL: URL?
    
    // MARK: - CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case sounds
        case recordingURL
    }
    
    // MARK: - Init
    
    init(sounds: [String], recordingURL: URL? = nil) {
        self.sounds = sounds
        self.recordingURL = recordingURL
    }
    
    // MARK: - Decodable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sounds = try container.decode([String].self, forKey: .sounds)
        recordingURL = try? container.decode(URL.self, forKey: .recordingURL)
    }
    
    // MARK: - Encodable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sounds, forKey: .sounds)
        try container.encode(recordingURL, forKey: .recordingURL)
    }
}

// MARK: - Date Formatting Helpers

private extension Date {
    var containerFormatted: Date {
        if let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) {
            return date
        }
        let dateFormatter = DateFormatter.drillSessionsContainer
        return dateFormatter.date(from: dateFormatter.string(from: self)) ?? self
    }
}

private extension DateFormatter {
    static let drillSessionsContainer: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter
    }()
}
