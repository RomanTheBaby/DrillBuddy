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
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(leaderboard: Leaderboard) {
        self.leaderboard = leaderboard
        self.sortedEntries = leaderboard.entries.sorted(by: {
            $0.totalTime < $1.totalTime
        })
    }
    
    // MARK: - View
    
    var body: some View {
        VStack {
            if sortedEntries.isEmpty {
                Text("Leaderboard is empty")
            } else {
                List {
                    ForEach(Array(sortedEntries.enumerated()), id: \.offset) { index, entry in
                        HStack {
                            Text("# \(index)")
                            Text(entry.username)
                            Spacer()
                            Text(entry.totalTime.minuteSecondMS)
                        }
                        .padding(8)
                    }
                }
            }
            
            Button(action: {
                dismiss()
            }, label: {
                Text("Dismiss")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
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
