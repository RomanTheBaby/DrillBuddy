//
//  WatchDataSynchronizer.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-24.
//

import Combine
import OSLog
import SwiftData
import WatchConnectivity


final class WatchDataSynchronizer: ObservableObject {
    
    // MARK: - Private Properties
    
    private var session: WCSession
    private let delegate: WCSessionDelegate
    private let modelContext: ModelContext
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Init
    
    init(session: WCSession = .default, modelContext: ModelContext) {
        self.delegate = WatchSessionDelegate(
            watchDataSyncHandler: WatchDataSyncHandler(modelContext: modelContext)
        )
        self.session = session
        self.modelContext = modelContext
        self.session.delegate = self.delegate
        self.session.activate()
    }
    
    // MARK: - Public Methods
    
    func synchronize(_ containers: [DrillsSessionsContainer]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let syncData = SyncData(drillContainers: containers.map(\.sendableRepresentation))
                let encodedSyncData = try jsonEncoder.encode(syncData)
                
                session.sendMessageData(encodedSyncData) { [unowned self] replyData in
                    do {
                        try self.handlerSyncReplyData(replyData, for: syncData)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } errorHandler: { error in
                    Logger.watchDataSynchronizer.error("Failed to send data to iPhone with error: \(error)")
                    assertionFailure()
                    continuation.resume(throwing: error)
                }
            } catch {
                Logger.watchDataSynchronizer.error("Failed to encode sync data with error: \(error)")
                assertionFailure()
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handlerSyncReplyData(_ replyData: Data, for syncData: SyncData) throws {
        Logger.watchDataSynchronizer.trace("Did Receive reply data")
        
        do {
            let syncResponse = try jsonDecoder.decode(SyncResponse.self, from: replyData)
            
            switch syncResponse.result {
            case .success:
                Logger.watchDataSynchronizer.trace("Sync response says success")

                if let drillContainersData = syncData.drillContainers {
                    let sentContainersStorage = drillContainersData.reduce([Date: DrillsSessionsContainer.SendableRepresentation]()) { partialResult, sendableContainer in
                        var result = partialResult
                        result[sendableContainer.date] = sendableContainer
                        return result
                    }
                    let sentContainersDates = Set<Date>(sentContainersStorage.keys)
                    let predicate = #Predicate<DrillsSessionsContainer> { container in
                        sentContainersDates.contains(container.date)
                    }
                    
                    do {
                        let syncedContainers = try modelContext.fetch(FetchDescriptor<DrillsSessionsContainer>(predicate: predicate))
                        
                        Logger.watchDataSynchronizer.error("Will remove synced data from \(syncedContainers.count) container(s)")
                        
                        for container in syncedContainers {
                            guard let sentContainer = sentContainersStorage[container.date] else {
                                continue
                            }
                            
                            let syncedDrills = container.drills.filter { drill in
                                sentContainer.drills.contains(where: { sentDrill in
                                    sentDrill.date == drill.date
                                })
                            }
                            
                            removeAudioRecordings(for: syncedDrills)
                            
                            if syncedDrills.count == container.drills.count {
                                Logger.watchDataSynchronizer.trace("Will delete full container for \(container.date)")
                                modelContext.delete(container)
                            } else {
                                Logger.watchDataSynchronizer.trace("Will \(syncedDrills.count) synced drills from container for \(container.date)")
                                syncedDrills.forEach(modelContext.delete)
                            }
                        }
                        
                    } catch {
                        Logger.watchDataSynchronizer.error("Failed to fetch drill containers to cleanup after sync")
                        throw error
                    }
                }
                
            case .error(let syncError):
                Logger.watchDataSynchronizer.error("Sync response retuns failure with description: \(syncError)")
                throw syncError
            }
            
        } catch {
            Logger.watchDataSynchronizer.error("Failed to decode sync response with error: \(error)")
            throw error
        }
    }
    
    private func removeAudioRecordings(for drills: [Drill]) {
        drills.forEach { drill in
            if let recordingURL = drill.recordingURL {
                do {
                    try FileManager.default.removeItem(at: recordingURL)
                } catch {
                    Logger.watchDataSynchronizer.error("Failed to remove audio recording at url: \(recordingURL) with error: \(error)")
                }
            }
        }
    }
}


// MARK: - Logger

private extension Logger {
    static let watchDataSynchronizer = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.WatchConnectivity",
        category: String(describing: WatchDataSynchronizer.self)
    )
}
