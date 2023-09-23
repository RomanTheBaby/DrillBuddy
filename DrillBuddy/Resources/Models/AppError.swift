//
//  AppError.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import Foundation


enum AppError {
    enum Microphone: LocalizedError {
        case noAccess
        case noAccessPreview
        
        var errorDescription: String? {
            switch self {
            case .noAccess:
                return "Microphone Access Required title"
            case .noAccessPreview:
                return "Cannot request microphone access from preview"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .noAccess, .noAccessPreview:
                return "No microphone access"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .noAccess:
                return "Please provide microphone access in phone settings"
            case .noAccessPreview:
                return "Please run app on simulator or device"
            }
        }
    }
}
