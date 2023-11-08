//
//  LeaderboardView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-07.
//

import SwiftUI

struct LeaderboardView: View {
    
    var leaderboard: Leaderboard
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview("Empty") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.empty)
}

#Preview("Full") {
    LeaderboardView(leaderboard: LeaderboardPreviewData.full)
}
