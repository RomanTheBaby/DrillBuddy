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
    
    // MARK: - Public Properties
    
    let subject = PassthroughSubject<SyncData, Never>()
    
    // MARK: - Private Properties
    
    private var session: WCSession
    private let delegate: WCSessionDelegate
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private var modelContext: ModelContext
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(session: WCSession = .default, modelContext: ModelContext) {
        self.delegate = WatchSessionDelegate(syncSubject: subject)
        self.session = session
        self.modelContext = modelContext
        self.session.delegate = self.delegate
        self.session.activate()
        
        cancellable = subject
            .receive(on: DispatchQueue.main)
            .sink { syncData in
                try? self.handleSyncData(syncData)
            }
    }
    
    // MARK: - Public Methods
    
    func synchronize(_ containers: [DrillsSessionsContainer]) {
        do {
            let encodedSyncData = try jsonEncoder.encode(SyncData(drillContainers: containers))
            
            session.sendMessageData(encodedSyncData) { [weak self] replyData in
                self?.handlerSyncReplyData(replyData)
            } errorHandler: { error in
                Logger.watchDataSynchronizer.error("Failed to send data to iPhone with error: \(error)")
                assertionFailure()
            }
        } catch {
            Logger.watchDataSynchronizer.error("Failed to encode sync data with error: \(error)")
            assertionFailure()
        }
    }
    
    // MARK: - Private Methods
    
    private func handleSyncData(_ syncData: SyncData) throws {
        guard let drillContainers = syncData.drillContainers else {
            Logger.watchDataSynchronizer.trace("No drill containers to sync")
            return
        }
        
        Logger.watchDataSynchronizer.trace("Did Receive \(drillContainers.count) drill containers to sync")
        
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
                    print(">>>Inserting new drill for: ", newContainer.title)
                    modelContext.insert(newContainer)
                }
            }
        } catch {
            Logger.watchDataSynchronizer.error("Failed to fetch existing drills with error: \(error)")
            assertionFailure()
            throw error
        }
    }
    
    private func handlerSyncReplyData(_ replyData: Data) {
        Logger.watchDataSynchronizer.trace("Did Receive reply data")
        
        do {
            let syncResponse = try jsonDecoder.decode(SyncResponse.self, from: replyData)
            
            switch syncResponse.result {
            case .success:
                Logger.watchDataSynchronizer.info("Sync response says success")
                Logger.watchDataSynchronizer.error("Sync response says success")
                
            case .error(let errorDescription):
                Logger.watchDataSynchronizer.error("Sync response retuns failure with description: \(errorDescription)")
            }
            
        } catch {
            Logger.watchDataSynchronizer.error("Failed to decode sync response with error: \(error)")
            assertionFailure()
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
