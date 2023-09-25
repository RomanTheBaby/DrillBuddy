//
//  SyncResponse.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-25.
//

import Foundation


struct SyncResponse: Codable {
    struct SyncError: LocalizedError, Codable {
        var failureReason: String?
        var errorDescription: String?
        var recoverySuggestion: String?
    }
    
    enum SyncResult: Codable {
        case success
        case error(SyncError)
    }
    
    var result: SyncResult
}

extension SyncResponse.SyncError {
    init(error: Error) {
        let userInfo = (error as NSError).userInfo
        let localizedError = error as? LocalizedError
        failureReason = {
            if let failureReason = localizedError?.failureReason {
                return failureReason
            }
            
            if let failureReason = userInfo[NSLocalizedFailureReasonErrorKey] as? String {
                return failureReason
            }
            
            return "Error"
        }()
        errorDescription = localizedError?.errorDescription ?? error.localizedDescription
        recoverySuggestion = {
            if let failureReason = localizedError?.recoverySuggestion {
                return failureReason
            }
            
            return userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
        }()
    }
}
