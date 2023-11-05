//
//  LocalizedErrorInfo.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-01.
//

import Foundation

struct LocalizedErrorInfo: LocalizedError {
    var failureReason: String? = nil
    var errorDescription: String?
    var recoverySuggestion: String? = nil
}

extension LocalizedErrorInfo {
    init?(error: Error?) {
        guard let error else {
            return nil
        }
        let localizedError = error as? LocalizedError
        failureReason = localizedError?.failureReason ?? "Error"
        errorDescription = localizedError?.errorDescription ?? error.localizedDescription
        recoverySuggestion = localizedError?.recoverySuggestion
    }
}
