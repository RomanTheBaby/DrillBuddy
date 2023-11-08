//
//  LeaderboardPreviewData.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-07.
//

import Foundation

actor LeaderboardPreviewData {
    static let empty = Leaderboard(id: "empty", entries: [], tournamentID: TournamentPreviewData.mock.id)
    static let full = Leaderboard(
        id: "empty",
        entries:
            Array(repeating: 0, count: 10).enumerated().map { index, _ -> Leaderboard.Entry in
                Leaderboard.Entry(
                    userId: "index: \(index)",
                    username: "User \(index)",
                    recordingDate: Date().addingTimeInterval(-(3600 * (Double(index) + 1))),
                    recordingData: try! Data(contentsOf: URL(string: "http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")!),
                    firstShotDelay: TimeInterval.random(in: 0.2...3),
                    shotsSplit: TimeInterval.random(in: 0.5...1.7),
                    totalTime: TimeInterval.random(in: 1...10)
                )
                
            },
        tournamentID: TournamentPreviewData.mock.id
    )
}
