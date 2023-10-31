//
//  Tournament.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-30.
//

import Foundation

enum GunType {
    case any
    case pistol
    case rifle
    case shotgun
    
    var description: String {
        switch self {
        case .any:
            return "Any"
        case .pistol:
            return "Pistol"
        case .rifle:
            return "Rifle"
        case .shotgun:
            return "Shotgun"
        }
    }
}

struct Tournament: Identifiable {
    
    struct Requirements {
        var gunType: GunType = .any
        var maxShotsCount: Int
        var maxTime: TimeInterval
    }
    
    var id: UUID = UUID()
    
    var startDate: Date
    var endDate: Date
    
    var title: String
    var description: String
    var requirements: Requirements
    
    var recordingConfiguration: DrillRecordingConfiguration = .default
}
