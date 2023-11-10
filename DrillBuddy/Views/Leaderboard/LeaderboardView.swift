//
//  LeaderboardView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-07.
//

import SwiftUI

// MARK: - LeaderboardView

struct LeaderboardView: View {
    
    // MARK: - Properties
    
    private let searchableUserId: String?
    private let leaderboard: Leaderboard
    private let sortedEntries: [Leaderboard.Entry]
    
    @State private var entryDetail: Leaderboard.Entry?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(leaderboard: Leaderboard, searchableUserId: String? = nil) {
        self.leaderboard = leaderboard
        self.searchableUserId = searchableUserId
        self.sortedEntries = leaderboard.entries.sorted(by: {
            $0.totalTime < $1.totalTime
        })
    }
    
    // MARK: - View
    
    var body: some View {
        VStack {
            if sortedEntries.isEmpty {
                Spacer()
                Text("Leaderboard is empty")
                    .font(.system(.title, weight: .bold))
                Spacer()
            } else {
                List {
                    ForEach(Array(sortedEntries.enumerated()), id: \.offset) { index, entry in
                        Button(action: {
                            entryDetail = entry
                        }, label: {
                            LeaderboardEntryView(
                                position: index + 1,
                                entry: entry
                            )
                            .listRowInsets(EdgeInsets())
                        })
                        .buttonStyle(.plain)
                        .listRowBackground(entry.userId == searchableUserId ? Color.red : Color(uiColor: UIColor.systemBackground))
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
        .sheet(item: $entryDetail) { entry in
            LeaderboardEntryDetailView(
                position: (sortedEntries.firstIndex(of: entry) ?? -1) + 1,
                leaderboardId: leaderboard.id,
                entry: entry,
                canBeReported: entry.userId != searchableUserId
            )
        }
    }
}

// MARK: - LeaderboardEntryView

private struct LeaderboardEntryView: View {
    let position: Int
    let entry: Leaderboard.Entry
    
    var body: some View {
        HStack {
            Text("# \(position)")
                .fontWeight(.bold)
                .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(entry.username)
                    .font(.system(.callout, weight: .regular))
                HStack(spacing: 2) {
                    Text(entry.firstShotDelay.secondMS)
                    Text("/")
                    Text(entry.shotsSplit.secondMS)
                }
                .font(.system(.footnote, weight: .light))
            }
            Spacer()
            Text(entry.totalTime.minuteSecondMS)
        }
        .padding(8)
    }
}

// MARK: - Time Interval Extension

private extension TimeInterval {
    var minuteSecondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
    
    var secondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
}

// MARK: - Previews

#Preview("Empty") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.empty)
}

#Preview("Full") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.full)
}

#Preview("Full / user") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.full, searchableUserId: LeaderboardPreviewData.full.entries[11].userId)
}
