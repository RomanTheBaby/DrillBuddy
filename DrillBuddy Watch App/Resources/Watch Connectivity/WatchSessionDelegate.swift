//
//  WatchSessionDelegate.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import Combine
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

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
            LogManager.log(.error, module: .watchSessionDelegate, message: "Failed to activate watch session with error: \(error)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        DispatchQueue.main.async { [self] in
            LogManager.log(.trace, module: .watchSessionDelegate, message: "Did receive message data")
            do {
                let syncData = try jsonDecoder.decode(SyncData.self, from: messageData)
                try watchDataSyncHandler.handleSyncData(syncData)
                send(syncResult: .success, to: replyHandler)
            } catch {
                LogManager.log(.error, module: .watchSessionDelegate, message: "Failed to sync data with error: \(error)")
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
        LogManager.log(.trace, module: .watchSessionDelegate, message: "Session did deactivate. Activating new one")
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
    
    // MARK: - Private Methods
    
    private func send(syncResult: SyncResponse.SyncResult, to replyHandler: @escaping (Data) -> Void) {
        LogManager.log(.trace, module: .watchSessionDelegate, message: "Sending sync response \(syncResult)")
        do {
            let encodedSencResponse = try jsonEncoder.encode(SyncResponse(result: syncResult))
            replyHandler(encodedSencResponse)
        } catch {
            LogManager.log(.error, module: .watchSessionDelegate, message: "Failed to encode SyncResponse with error error: \(error)")
            assertionFailure()
        }
    }
}
