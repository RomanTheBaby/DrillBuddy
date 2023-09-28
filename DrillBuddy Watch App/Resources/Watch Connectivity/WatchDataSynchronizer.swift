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
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Init
    
    init(session: WCSession = .default, modelContext: ModelContext) {
        self.delegate = WatchSessionDelegate(
            watchDataSyncHandler: WatchDataSyncHandler(modelContext: modelContext)
        )
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
    }
    
    // MARK: - Public Methods
    
    func synchronize(_ containers: [DrillsSessionsContainer]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let encodedSyncData = try jsonEncoder.encode(SyncData(drillContainers: containers.map(\.sendableRepresentation)))
                
                session.sendMessageData(encodedSyncData) { [unowned self] replyData in
                    do {
                        try self.handlerSyncReplyData(replyData)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } errorHandler: { error in
                    Logger.watchDataSynchronizer.error("Failed to send data to iPhone with error: \(error)")
//                    assertionFailure()
                    continuation.resume(throwing: error)
                }
            } catch {
                Logger.watchDataSynchronizer.error("Failed to encode sync data with error: \(error)")
//                assertionFailure()
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handlerSyncReplyData(_ replyData: Data) throws {
        Logger.watchDataSynchronizer.trace("Did Receive reply data")
        
        do {
            let syncResponse = try jsonDecoder.decode(SyncResponse.self, from: replyData)
            
            switch syncResponse.result {
            case .success:
                Logger.watchDataSynchronizer.error("Sync response says success")
                
            case .error(let syncError):
                Logger.watchDataSynchronizer.error("Sync response retuns failure with description: \(syncError)")
                throw syncError
            }
            
        } catch {
            Logger.watchDataSynchronizer.error("Failed to decode sync response with error: \(error)")
//            assertionFailure()
            throw error
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
