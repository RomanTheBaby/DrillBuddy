//
//  Logger.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-11.
//

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif
import Foundation
import OSLog

struct LogManager {
    
    // MARK: - Module
    
    enum Module: String {
        case audioRecorder = "AudioRecorder"
        case audioSessionManager = "AudioSessionManager"
        case audioView = "AudioView"
        case authenticationService = "AuthenticationService"
        case firestoreService = "FirestoreService"
        case drillRecording = "DrillRecordingViewModel"
        case mainTabView = "MainTabView"
        case sessionsListView = "SessionsListView"
        case soundIdentifier = "SoundIdentifier"
        case watchDataSyncHandler = "WatchDataSyncHandler"
        case watchDataSynchronizer = "WatchDataSynchronizer"
        case watchSessionDelegate = "WatchSessionDelegate"
    }
    
    // MARK: - Level
    
    enum Level {
        case critical
        case debug
        case error
        case fault
        case info
        case notice
        case trace
        case warning
    }
    
    // MARK: - Public Methods
    
    static func log(
        _ level: Level,
        module: Module,
        message: String,
        inFile file: String = #file,
        inFunction function: String = #function,
        onLine line: Int = #line
    ) {
        let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? module.rawValue,
            category: module.rawValue
        )
        
        let updatedMessage = "\(file.components(separatedBy: "/").last ?? "_"):\(function):\(line) \(message)"
        
        switch level {
        case .critical:
            logger.critical("\(updatedMessage)")
        case .debug:
            logger.debug("\(updatedMessage)")
        case .error:
            logger.error("\(updatedMessage)")
        case .fault:
            logger.fault("\(updatedMessage)")
        case .info:
            logger.info("\(updatedMessage)")
        case .notice:
            logger.notice("\(updatedMessage)")
        case .trace:
            logger.trace("\(updatedMessage)")
        case .warning:
            logger.warning("\(updatedMessage)")
        }
        
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(updatedMessage)
        #endif
    }
}

//Crashlytics.crashlytics().log("Higgs-Boson detected! Bailing out…, \(attributesDict)")
