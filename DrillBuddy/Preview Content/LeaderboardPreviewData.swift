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
            [
                Leaderboard.Entry(
                    userId: "slowest user",
                    username: "Should be last",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 10,
                    shotsSplit: 15,
                    totalTime: 30
                ),
                Leaderboard.Entry(
                    userId: "second user",
                    username: "Should be second",
                    recordingDate: Date().addingTimeInterval(-(3600 * 5)),
                    recordingData: Data(),
                    firstShotDelay: 0.3,
                    shotsSplit: 0.7,
                    totalTime: 2.1
                ),
                Leaderboard.Entry(
                    userId: "index: 1",
                    username: "Should be 1",
                    recordingDate: Date().addingTimeInterval(-(3600 * 1)),
                    recordingData: Data(),
                    firstShotDelay: 0.2,
                    shotsSplit: 0.6,
                    totalTime: 2
                ),
                Leaderboard.Entry(
                    userId: "third user",
                    username: "Should be third",
                    recordingDate: Date().addingTimeInterval(-(3600 * 5)),
                    recordingData: Data(),
                    firstShotDelay: 0.4,
                    shotsSplit: 0.9,
                    totalTime: 2.4
                ),
                Leaderboard.Entry(
                    userId: "4th user",
                    username: "Should be 4th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.4,
                    shotsSplit: 0.9,
                    totalTime: 2.5
                ),
                Leaderboard.Entry(
                    userId: "5th user",
                    username: "Should be 5th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.45,
                    shotsSplit: 0.95,
                    totalTime: 2.6
                ),
                Leaderboard.Entry(
                    userId: "6th user",
                    username: "Should be 6th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 0.95,
                    totalTime: 3
                ),
                Leaderboard.Entry(
                    userId: "7th user",
                    username: "Should be 7th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 3.2
                ),
                Leaderboard.Entry(
                    userId: "8th user",
                    username: "Should be 8th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 1.6,
                    shotsSplit: 0.5,
                    totalTime: 4.5
                ),
                Leaderboard.Entry(
                    userId: "9th user",
                    username: "Should be 9th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 1.6,
                    shotsSplit: 1,
                    totalTime: 4.6
                ),
                Leaderboard.Entry(
                    userId: "10th user",
                    username: "Should be 10th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 4.9
                ),
                Leaderboard.Entry(
                    userId: "11th user",
                    username: "Should be 11th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 5.2
                ),
                Leaderboard.Entry(
                    userId: "12th user",
                    username: "Should be 12th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 8
                ),
                Leaderboard.Entry(
                    userId: "13th user",
                    username: "Should be 13th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 8.5
                ),
                Leaderboard.Entry(
                    userId: "14th user",
                    username: "Should be 14th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 8.8
                ),
                Leaderboard.Entry(
                    userId: "15th user",
                    username: "Should be 15th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 9
                ),
                Leaderboard.Entry(
                    userId: "15th user",
                    username: "Should be 15th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 9.2
                ),
                Leaderboard.Entry(
                    userId: "16th user",
                    username: "Should be 16th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 9.77
                ),
                Leaderboard.Entry(
                    userId: "17th user",
                    username: "Should be 17th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 10.2
                ),
                Leaderboard.Entry(
                    userId: "18th user",
                    username: "Should be 18th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 11
                ),
                Leaderboard.Entry(
                    userId: "19th user",
                    username: "Should be 19th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 13
                ),
                Leaderboard.Entry(
                    userId: "20th user",
                    username: "Should be 20th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 0.6,
                    shotsSplit: 1,
                    totalTime: 15.4
                ),
                Leaderboard.Entry(
                    userId: "21th user",
                    username: "Should be 21th",
                    recordingDate: Date().addingTimeInterval(-(3600 * 2)),
                    recordingData: Data(),
                    firstShotDelay: 21,
                    shotsSplit: 0.43,
                    totalTime: 22.3
                ),
            ],
        tournamentID: TournamentPreviewData.mock.id
    )
}
