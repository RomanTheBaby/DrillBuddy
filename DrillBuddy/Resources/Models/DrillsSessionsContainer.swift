//
//  DrillsSessionsContainer.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import Foundation
import SwiftData

@Model
class DrillsSessionsContainer: Identifiable {
    
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
    
    init(date: Date = Date(), drills: [Drill]) {
        self.date = date.containerFormatted
        self.drills = drills
    }
}

@Model
class Drill: Identifiable {
    @Attribute(.unique)
    var id: UUID = UUID()
    var sounds: [String]
    var recordingURL: URL?
    
    init(sounds: [String], recordingURL: URL? = nil) {
        self.sounds = sounds
        self.recordingURL = recordingURL
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
