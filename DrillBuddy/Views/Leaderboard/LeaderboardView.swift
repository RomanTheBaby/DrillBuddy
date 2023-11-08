//
//  LeaderboardView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-07.
//

import SwiftUI

struct LeaderboardView: View {
    
    // MARK: - Properties
    
    private let leaderboard: Leaderboard
    private let sortedEntries: [Leaderboard.Entry]
    
    // MARK: - Init
    
    init(leaderboard: Leaderboard) {
        self.leaderboard = leaderboard
        self.sortedEntries = leaderboard.entries.sorted(by: {
            $0.totalTime < $1.totalTime
        })
    }
    
    // MARK: - View
    
    var body: some View {
        if sortedEntries.isEmpty {
            Text("Leaderboard is empty")
        } else {
            List {
                ForEach(Array(sortedEntries.enumerated()), id: \.offset) { index, entry in
                    HStack {
                        Text("# \(index) |")
                        Text(entry.username)
                        Spacer()
                        Text(
                            Duration.seconds(entry.totalTime)
                                .formatted(.time(pattern: .minuteSecond))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Empty") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.empty)
}

#Preview("Full") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.full)
}
