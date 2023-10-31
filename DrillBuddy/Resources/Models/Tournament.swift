//
//  Tournament.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-30.
//

import Foundation

struct Tournament: Identifiable {
    
    struct Requirements {
        var gunType: GunType = .any
        var gunActionType: GunActionType = .any
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
