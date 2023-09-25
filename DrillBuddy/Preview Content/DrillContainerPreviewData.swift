//
//  DrillContainerPreviewData.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import Foundation
import SwiftData

actor DrillSessionsContainerSampleData {
    
    // MARK: - Private Properties
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter
    }()
    
    // MARK: - Public Properties
    
    @MainActor
    static var container: ModelContainer = {
        let schema = Schema([DrillsSessionsContainer.self, Drill.self])
        let configuration = ModelConfiguration.init(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        
        previewModels.forEach(container.mainContext.insert)
        return container
    }()
    
    @MainActor static let previewModels: [DrillsSessionsContainer] = [
        DrillsSessionsContainer(
            drills: [
                Drill(sounds: ["1", "2", "3", "4"]),
                Drill(sounds: ["5", "7", "3", "4"], recordingURL: URL(string: "google.com")!),
                Drill(sounds: ["0", "9", "3", "4"]),
            ]
        ),
        DrillsSessionsContainer(
            date: dateFormatter.date(from: "08-Aug-2023") ?? Date().addingTimeInterval(-(3600 * 24)),
            drills: [
                Drill(sounds: ["5", "6", "7", "8"]),
                Drill(sounds: ["1", "2", "3", "4"]),
                Drill(sounds: ["2", "3", "3", "4"], recordingURL: URL(string: "google.com")!),
            ]
        ),
        DrillsSessionsContainer(
            date: dateFormatter.date(from: "11-Sep-2021") ?? Date().addingTimeInterval(-(3600 * 24)),
            drills: [
                Drill(sounds: ["1", "2", "3", "4"]),
                Drill(sounds: ["1", "5", "2", "4"]),
            ]
        ),
        DrillsSessionsContainer(
            date: dateFormatter.date(from: "08-Dec-1996") ?? Date().addingTimeInterval(-(3600 * 52)),
            drills: [
                Drill(sounds: ["1", "2", "3", "4"]),
                Drill(sounds: ["1", "2"]),
                Drill(sounds: ["1", "2", "8", "4"]),
                Drill(sounds: ["1", "2", "9", "0"], recordingURL: URL(string: "google.com")!),
            ]
        ),
    ]
}
