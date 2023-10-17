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
    static let container: ModelContainer = {
        let schema = Schema([DrillsSessionsContainer.self, Drill.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            
            previewDrillsInfo.forEach { drillsContainer, drills in
                modelContainer.mainContext.insert(drillsContainer)
                drillsContainer.addDrills(drills)
            }
            
            return modelContainer
        } catch {
            fatalError("Failed with error: \(error)")
        }
    }()
    
    @MainActor
    static let previewDrillsContainers: [DrillsSessionsContainer] = {
        let schema = Schema([DrillsSessionsContainer.self, Drill.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            
            return previewDrillsInfo.map { drillsContainer, drills -> DrillsSessionsContainer in
                modelContainer.mainContext.insert(drillsContainer)
                drillsContainer.addDrills(drills)
                return drillsContainer
            }
        } catch {
            fatalError("Failed with error: \(error)")
        }
    }()
    
    @MainActor static private let previewDrillsInfo: [(container: DrillsSessionsContainer, drills: [Drill])] = {
        let firstContainer = DrillsSessionsContainer()
        let firstContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-5),
                sounds: ["1", "2", "3", "4"]
            ),
            Drill(
                date: Date().addingTimeInterval(-10),
                sounds: ["5", "7", "3", "4"],
                recordingURL: URL(string: "google.com")!
            ),
            Drill(
                date: Date().addingTimeInterval(-15),
                sounds: ["0", "9", "3", "4"]
            ),
        ]
        
        let secondContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "08-Aug-2023") ?? Date().addingTimeInterval(-(3600 * 24))
        )
        let secondContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-20),
                sounds: ["5", "6", "7", "8"]
            ),
            Drill(
                date: Date().addingTimeInterval(-25),
                sounds: ["1", "2", "3", "4"]
            ),
            Drill(
                date: Date().addingTimeInterval(-30),
                sounds: ["2", "3", "3", "4"], recordingURL: URL(string: "google.com")!
            ),
        ]
        
        let thirdContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "11-Sep-2021") ?? Date().addingTimeInterval(-(3600 * 24))
        )
        let thirdContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-35),
                sounds: ["1", "2", "3", "4"]
            ),
            Drill(
                date: Date().addingTimeInterval(-40),
                sounds: ["1", "5", "2", "4"]
            ),
        ]
        
        let fourthContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "08-Dec-1996") ?? Date().addingTimeInterval(-(3600 * 52))
        )
        let fourthContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-45),
                sounds: ["1", "2", "3", "4"]
            ),
            Drill(
                date: Date().addingTimeInterval(-50),
                sounds: ["1", "2"]
            ),
            Drill(
                date: Date().addingTimeInterval(-60),
                sounds: ["1", "2", "8", "4"]
            ),
            Drill(
                date: Date().addingTimeInterval(-70),
                sounds: ["1", "2", "9", "0"], recordingURL: URL(string: "google.com")!
            ),
        ]
        
        return [
            (container: firstContainer, drills: firstContainerDrills),
            (container: secondContainer, drills: secondContainerDrills),
            (container: thirdContainer, drills: thirdContainerDrills),
            (container: fourthContainer, drills: fourthContainerDrills),
        ]
    }()
}
