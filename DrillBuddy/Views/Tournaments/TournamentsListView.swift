//
//  TournamentsListView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-28.
//

import SwiftUI

// MARK: - TournamentsListView

struct TournamentsListView: View {
    
    var tournaments: [Tournament]
    
    var body: some View {
        List {
            ForEach(tournaments) { tournament in
                // This ZStack is to hide NavLink right arrow
                ZStack {
                    TournamentCardView(tournament: tournament)
                    NavigationLink(destination: TournamentDetailView(tournament: tournament)) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                #if !os(watchOS)
                .listRowSeparator(.hidden)
                #endif
            }
        }
        #if !os(watchOS)
        .listRowSpacing(16)
        #endif
        .navigationTitle("Tournaments")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - TournamentCardView

private struct TournamentCardView: View {
    
    var tournament: Tournament
    
    private var timeText: String {
        if tournament.requirements.maxTime == 0 {
            #if os(watchOS)
            return "Unlim."
            #else
            return "Unlimited"
            #endif
        }
        
        return "\(tournament.requirements.maxTime)"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(tournament.title)
//                .font(.system(.title, weight: .medium))
                .font(.system(.title3, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
//#if !os(watchOS)
            
            HStack {
                Image(systemName: "calendar")
                
                if Date() > tournament.endDate {
                    Text("ENDED")
                        .font(.callout)
                        .foregroundStyle(Color.red)
                } else {
                    Text("\(tournament.startDate.tournamentFormatted) - \(tournament.endDate.tournamentFormatted)")
                }
                
                Spacer()
            }
            
            HStack {
                Text("\(tournament.requirements.maxShotsCount) shot(s)")
                Spacer()
                HStack {
                    Text(timeText)
                    Image(systemName: "timer")
                }
            }
        }
    }
}

private extension Date {
    var tournamentFormatted: String {
        self.formatted(.dateTime.day().month())
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        TournamentsListView(
            tournaments: [
                Tournament(
                    startDate: Date().addingTimeInterval(-(3600 * 48)),
                    endDate: Date().addingTimeInterval(-(3600 * 24)),
                    title: "3-shot competition",
                    description: "",
                    requirements: Tournament.Requirements(maxShotsCount: 3, maxTime: 20)
                ),
                Tournament(
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(3600 * 24),
                    title: "3-shot competition",
                    description: "This is a simple 3 shot competition to test your basic shooting skills.\nUpon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot",
                    requirements: Tournament.Requirements(maxShotsCount: 3, maxTime: 0),
                    recordingConfiguration: DrillRecordingConfiguration(maxShots: 3, maxSessionDelay: 4, shouldRecordAudio: true)
                )
            ]
        )
    }
}
