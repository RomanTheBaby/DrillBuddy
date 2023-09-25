//
//  WatchSessionDelegate.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import Combine
import OSLog
import WatchConnectivity

// MARK: - SyncData

struct SyncData: Codable {
    var drillContainers: [DrillsSessionsContainer]?
}

struct SyncResponse: Codable {
    enum SyncResult: Codable {
        case success
        case error(String)
    }
    
    var result: SyncResult
}

// MARK: - WatchSessionDelegate

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    // MARK: - Properties
    
    let syncSubject: PassthroughSubject<SyncData, Never>
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Init
    
    init(syncSubject: PassthroughSubject<SyncData, Never>) {
        self.syncSubject = syncSubject
        super.init()
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            Logger.watchSession.error("Failed to activate watch session with error: \(error, privacy: .public)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        Logger.watchSession.trace("Did receive message data")
        do {
            let syncData = try jsonDecoder.decode(SyncData.self, from: messageData)
            syncSubject.send(syncData)
            send(syncResult: .success, to: replyHandler)
        } catch {
            Logger.watchSession.error("Failed to decode SyncData with error error: \(error, privacy: .public)")
            assertionFailure()
            send(syncResult: .error(error.localizedDescription), to: replyHandler)
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
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.WatchConnectivity",
        category: String(describing: WatchSessionDelegate.self)
    )
}
