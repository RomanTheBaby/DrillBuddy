//
//  TournamentPreviewData.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-31.
//

import Foundation

actor TournamentPreviewData {
    static let mock: Tournament = {
        Tournament(
            startDate: Date().addingTimeInterval(-(3600 * 24)),
            endDate: Date().addingTimeInterval(3600 * 24),
            title: "3-shot competition",
            description: "   This is a simple 3 shot competition to test your basic shooting skills.\n   Upon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot.\n  Your result will be displayed to everyone on the leaderboard. You can submit only one entry for each tournament.",
            requirements: Tournament.Requirements(
                gunActionType: .semiAuto,
                maxTime: 20
            ),
            recordingConfiguration: DrillRecordingConfiguration(
                maxShots: 3,
                maxSessionDelay: 3,
                shouldRecordAudio: true
            )
        )
    }()
    
    static let mockEnded: Tournament = {
        Tournament(
            startDate: Date().addingTimeInterval(-(3600 * 48)),
            endDate: Date().addingTimeInterval(-(3600 * 24)),
            title: "3-shot competition",
            description: "   This is a simple 3 shot competition to test your basic shooting skills.\n   Upon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot.\n  Your result will be displayed to everyone on the leaderboard. You can submit only one entry for each tournament.",
            requirements: Tournament.Requirements(
                maxTime: 20
            ),
            recordingConfiguration: DrillRecordingConfiguration(
                maxShots: 3,
                maxSessionDelay: 3,
                shouldRecordAudio: true
            )
        )
    }()
}

