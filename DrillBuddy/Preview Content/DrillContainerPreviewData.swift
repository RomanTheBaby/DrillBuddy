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
    
    static let testAudioURL: URL = {
        guard let testAudioPath = Bundle.main.path(forResource: "Hydrogen", ofType: "mp3") else {
            fatalError("Could not find test audio")
        }
        
        return URL(fileURLWithPath: testAudioPath)
    }()
    
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
        let firstContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "10-Nov-2022") ?? Date().addingTimeInterval(-(((3600 * 24) * 365) * 1))
        )
        let firstContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-5),
                sounds: [
                    DrillEntry(time: 5, confidence: 1),
                    DrillEntry(time: 10, confidence: 1),
                    DrillEntry(time: 15, confidence: 1),
                    DrillEntry(time: 25, confidence: 1),
                ], 
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-10),
                sounds: [
                    DrillEntry(time: 3, confidence: 0.85),
                    DrillEntry(time: 4, confidence: 0.95),
                    DrillEntry(time: 5, confidence: 1),
                    DrillEntry(time: 7, confidence: 1),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-15),
                sounds: [
                    DrillEntry(time: 3, confidence: 0.8),
                    DrillEntry(time: 4, confidence: 0.9),
                    DrillEntry(time: 8, confidence: 1),
                    DrillEntry(time: 9, confidence: 1),
                ],
                recordingConfiguration: .default
            ),
        ]
        
        let secondContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "24-Aug-2014") ?? Date().addingTimeInterval(-(((3600 * 24) * 365) * 10))
        )
        let secondContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-20),
                sounds: [
                    DrillEntry(time: 5, confidence: 0.9),
                    DrillEntry(time: 6, confidence: 0.9),
                    DrillEntry(time: 7, confidence: 0.9),
                    DrillEntry(time: 8, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-25),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 3, confidence: 0.9),
                    DrillEntry(time: 4, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-30),
                sounds: [
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 3, confidence: 0.9),
                    DrillEntry(time: 3.5, confidence: 0.9),
                    DrillEntry(time: 4, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
        ]
        
        let thirdContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "11-Sep-2021") ?? Date().addingTimeInterval(-(((3600 * 24) * 365) * 15))
        )
        let thirdContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-35),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 3, confidence: 0.9),
                    DrillEntry(time: 4, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-40),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 4, confidence: 0.9),
                    DrillEntry(time: 5, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
        ]
        
        let fourthContainer = DrillsSessionsContainer(
            date: dateFormatter.date(from: "08-Dec-1996") ?? Date().addingTimeInterval(-(((3600 * 24) * 365) * 15))
        )
        let fourthContainerDrills = [
            Drill(
                date: Date().addingTimeInterval(-45),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 3, confidence: 0.9),
                    DrillEntry(time: 4, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-50),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-60),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 4, confidence: 0.9),
                    DrillEntry(time: 8, confidence: 0.9),
                ],
                recordingConfiguration: .default
            ),
            Drill(
                date: Date().addingTimeInterval(-70),
                sounds: [
                    DrillEntry(time: 1, confidence: 0.9),
                    DrillEntry(time: 2, confidence: 0.9),
                    DrillEntry(time: 9, confidence: 0.9),
                    DrillEntry(time: 12, confidence: 0.9),
                ],
                recordingConfiguration: .default
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
