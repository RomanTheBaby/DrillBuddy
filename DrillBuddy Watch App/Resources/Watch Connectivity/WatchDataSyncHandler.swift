//
//  WatchDataSyncHandler.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-25.
//

import Foundation
import OSLog
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
        guard let drillContainers = syncData.drillContainers else {
            Logger.watchSyncHandler.trace("No drill containers to sync")
            return
        }
        
        Logger.watchSyncHandler.trace("Did Receive \(drillContainers.count) drill containers to sync")
        
        do {
            let syncedContainersDates = Set<Date>(drillContainers.map(\.date))
            let predicate = #Predicate<DrillsSessionsContainer> { container in
                syncedContainersDates.contains(container.date)
            }
            let existing = try modelContext.fetch(FetchDescriptor<DrillsSessionsContainer>(predicate: predicate))
            let existingContainersDict = existing.reduce([Date: DrillsSessionsContainer]()) { partialResult, container in
                var result = partialResult
                result[container.id] = container
                return result
            }
            
            drillContainers.forEach { newContainer in
                if let localContainer = existingContainersDict[newContainer.id] {
                    print(">>>Already existing container found for: ", localContainer.title)
                } else {
                    modelContext.insert(newContainer)
                }
            }
        } catch {
            Logger.watchSyncHandler.error("Failed to fetch existing drills with error: \(error)")
//            assertionFailure()
            throw error
        }
    }
}

// MARK: - Logger

private extension Logger {
    static let watchSyncHandler = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.WatchDataSyncHandler",
        category: String(describing: WatchSessionDelegate.self)
    )
}
