//
//  WatchDataSyncHandler.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-25.
//

import Foundation
import SwiftData


class WatchDataSyncHandler {
    
    // MARK: - Private Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Init
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    func handleSyncData(_ syncData: SyncData) throws {
        guard let drillContainersData = syncData.drillContainers else {
            LogManager.log(.trace, module: .watchDataSyncHandler, message: "No drill containers to sync")
            return
        }
        
        LogManager.log(.trace, module: .watchDataSyncHandler, message: "Did Receive \(drillContainersData.count) drill containers to sync")
        
        do {
            let syncedContainersDates = Set<Date>(drillContainersData.map(\.date))
            let predicate = #Predicate<DrillsSessionsContainer> { container in
                syncedContainersDates.contains(container.date)
            }
            
            let existing = try modelContext.fetch(FetchDescriptor<DrillsSessionsContainer>(predicate: predicate))
            let existingContainersDict = existing.reduce([Date: DrillsSessionsContainer]()) { partialResult, container in
                var result = partialResult
                result[container.date] = container
                return result
            }
            
            drillContainersData.forEach { drillContainerData in
                if let localContainer = existingContainersDict[drillContainerData.date] {
                    let insertedDrillsCount = localContainer.addDrills(drillContainerData.drills.map(Drill.init(sendableRepresentation:)))
                    LogManager.log(.trace, module: .watchDataSyncHandler, message: "Container already exists for \(drillContainerData.date), inserted missing containers: \(insertedDrillsCount)")
                } else {
                    LogManager.log(.trace, module: .watchDataSyncHandler, message: "No container found for \(drillContainerData.date), inserting all data")
                    DrillsSessionsContainer(context: modelContext, sendableRepresentation: drillContainerData)
                }
            }
        } catch {
            LogManager.log(.error, module: .watchDataSyncHandler, message: "Failed to fetch existing drills with error: \(error)")
            assertionFailure()
            throw error
        }
    }
}
