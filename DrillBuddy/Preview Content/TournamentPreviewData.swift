//
//  TournamentPreviewData.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-31.
//

import Foundation
import SwiftData

actor TournamentPreviewData {
    static let mock: Tournament = {
        Tournament(
            id: "Mock-Tournament",
            startDate: Date().addingTimeInterval(-(3600 * 24)),
            endDate: Date().addingTimeInterval(3600 * 24), 
            isHidden: false,
            title: "3-shot competition",
            description: "   This is a simple 3 shot competition to test your basic shooting skills.\n   Upon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot.\n  Your result will be displayed to everyone on the leaderboard. You can submit only one entry for each tournament.",
            leaderboardID: "cqhoHabzfKpBvYc6zT0O",
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
            id: "Mock-Tournament-Ended",
            startDate: Date().addingTimeInterval(-(3600 * 48)),
            endDate: Date().addingTimeInterval(-(3600 * 24)), 
            isHidden: false,
            title: "3-shot competition",
            description: "   This is a simple 3 shot competition to test your basic shooting skills.\n   Upon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot.\n  Your result will be displayed to everyone on the leaderboard. You can submit only one entry for each tournament.",
            leaderboardID: UUID().uuidString,
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
    
    @MainActor
    static let container: ModelContainer = {
        let schema = Schema([TournamentEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            
            modelContainer.mainContext.insert(mockEntry)
            try! modelContainer.mainContext.save()
            
            return modelContainer
        } catch {
            fatalError("Failed with error: \(error)")
        }
    }()
    
    static let mockEntry = TournamentEntry(
        tournamentId: mock.id, 
        userId: UserStoragePreviewData.loggedIn.currentUser?.id ?? "mock_entry_userId",
        date: Date(),
        sounds: [
            DrillEntry(time: 1, confidence: 1),
            DrillEntry(time: 1.2, confidence: 1),
            DrillEntry(time: 1.5, confidence: 1),
            DrillEntry(time: 2, confidence: 1),
        ]
    )
}

