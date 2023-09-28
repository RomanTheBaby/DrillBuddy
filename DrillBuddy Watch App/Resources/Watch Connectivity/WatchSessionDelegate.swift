//
//  WatchSessionDelegate.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import Combine
import OSLog
import WatchConnectivity

// MARK: - WatchSessionDelegate

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    
    // MARK: - Private Properties
    
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    private let watchDataSyncHandler: WatchDataSyncHandler
    
    // MARK: - Init
    
    init(
        watchDataSyncHandler: WatchDataSyncHandler,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.watchDataSyncHandler = watchDataSyncHandler
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        
        super.init()
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            Logger.watchSession.error("Failed to activate watch session with error: \(error, privacy: .public)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        DispatchQueue.main.async { [self] in
            Logger.watchSession.trace("Did receive message data")
            do {
                let syncData = try jsonDecoder.decode(SyncData.self, from: messageData)
                try watchDataSyncHandler.handleSyncData(syncData)
                send(syncResult: .success, to: replyHandler)
            } catch {
                Logger.watchSession.error("Failed to sync data with error: \(error, privacy: .public)")
                assertionFailure()
                let syncError = SyncResponse.SyncError(error: error)
                send(syncResult: .error(syncError), to: replyHandler)
            }
        }
    }
    
    // iOS Protocol comformance
    // Not needed for this demo otherwise
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        Logger.watchSession.trace("Session did deactivate. Activating new one")
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
    
    // MARK: - Private Methods
    
    private func send(syncResult: SyncResponse.SyncResult, to replyHandler: @escaping (Data) -> Void) {
        do {
            let encodedSencResponse = try jsonEncoder.encode(SyncResponse(result: syncResult))
            replyHandler(encodedSencResponse)
        } catch {
            Logger.watchSession.error("Failed to encode SyncResponse with error error: \(error, privacy: .public)")
            assertionFailure()
        }
    }
}

// MARK: - Logger

private extension Logger {
    static let watchSession = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.WatchSessionDelegate",
        category: String(describing: WatchSessionDelegate.self)
    )
}
