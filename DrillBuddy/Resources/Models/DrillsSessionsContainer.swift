//
//  DrillsSessionsContainer.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import Foundation
import SwiftData

@Model
class DrillsSessionsContainer: Identifiable, Hashable {
    
    // MARK: - SendableRepresentation
    
    struct SendableRepresentation: Codable, Hashable {
        var date: Date
        var drills: [Drill.SendableRepresentation]
        
        lazy var title = DateFormatter.drillSessionsContainer.string(from: date)
    }
    
    // MARK: - Properties
    
    var title: String
    
    /// This date is at format of
    @Attribute(.unique) 
    private(set) var date: Date
    
    @Relationship(deleteRule: .cascade)
    private(set) var drills: [Drill]
    
    @Transient
    var sendableRepresentation: SendableRepresentation {
        SendableRepresentation(date: date, drills: drills.map(\.sendableRepresentation))
    }
    
    // MARK: - Init
    
    init(title: String? = nil, date: Date = Date()) {
        self.title = title ?? DateFormatter.drillSessionsContainer.string(from: date)
        self.date = date.containerFormatted
        self.drills = []
    }
    
    @discardableResult
    convenience init(
        context: ModelContext,
        title: String? = nil,
        date: Date = Date(),
        drills: [Drill] = []
    ) {
        self.init(
            title: title,
            date: date
        )
        
        context.insert(self)
        addDrills(drills)
    }
    
    @discardableResult
    convenience init(context: ModelContext, sendableRepresentation: SendableRepresentation) {
        self.init(
            context: context,
            date: sendableRepresentation.date,
            drills: sendableRepresentation.drills.map(Drill.init(sendableRepresentation:))
        )
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(drills.map(\.hashValue))
    }
    
    // MARK: - Public Methods
    
    /// Returns number of drill that were inserted. 0 - if all `insertingDrills` were already in the container
    @discardableResult
    func addDrills(_ insertingDrills: [Drill]) -> Int {
        let existingDrillDates = Set<Date>(drills.map(\.date))
        
        let missingDrills = insertingDrills.filter {
            existingDrillDates.contains($0.date) == false
        }
        
        guard missingDrills.isEmpty == false else {
            return 0
        }
        
        missingDrills.forEach {
            $0.container = self
        }
        
        drills.append(contentsOf: missingDrills)
        return missingDrills.count
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
