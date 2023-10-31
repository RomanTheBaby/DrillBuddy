//
//  TournamentDetailView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-28.
//

import SwiftUI

struct TournamentDetailView: View {
    
    var tournament: Tournament
    
    var body: some View {
        VStack(spacing: 16) {
            Text(tournament.title)
                .font(.system(.title, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Max Shots:")
                        .fontWeight(.medium)
                    Text("\(tournament.requirements.maxShotsCount == 0 ? "Unlimited" : "\(tournament.requirements.maxShotsCount)")")
                    Spacer()
                }
                
                HStack {
//                    Image(systemName: "timer")
                    Text("Time Limit:")
                        .fontWeight(.medium)
                    Text("\(tournament.requirements.maxTime == 0 ? "Unlimited" : "\(tournament.requirements.maxTime)")")
                    Spacer()
                }
                
                HStack {
                    Text("Start:")
                        .fontWeight(.medium)
                    Text(tournament.startDate.formatted(.dateTime.day().month().hour().minute()))
                }
                
                HStack {
                    Text("End:")
                        .fontWeight(.medium)
                    Text(tournament.endDate.formatted(.dateTime.day().month().hour().minute()))
                    
                    if Date() > tournament.endDate {
                        Text("ended")
                            .foregroundStyle(Color.red)
                            .font(.callout)
                    }
                }
                HStack {
                    Text("Gun Type:")
                        .fontWeight(.medium)
                    Text(tournament.requirements.gunType.description)
                }
            }
            
            Text(tournament.description)
            Spacer()
            
            if Date() > tournament.endDate {
                Text("Submissins closed. Tournament has ended")
                    .foregroundStyle(Color.gray)
            } else {
                Text("WARNING: You can enter tournament only once!")
                    .foregroundStyle(Color.red)
                    .font(.footnote)
                
                NavigationLink(
                    destination:
                        DrillConfigurationView(
                            showCloseButton: false,
                            isConfigurationEditable: false,
                            configuration: tournament.recordingConfiguration
                        )
                ) {
                    Text("Enter Tournament")
                        .fontWeight(.bold)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            
        }
        .padding(.horizontal)
        
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TournamentDetailView(
            tournament: Tournament(
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600 * 24),
                title: "3-shot competition",
                description: "   This is a simple 3 shot competition to test your basic shooting skills.\n   Upon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot.\n  Your result will be displayed to everyone on the leaderboard. You can submit only one entry for each tournament.",
                requirements: Tournament.Requirements(maxShotsCount: 3, maxTime: 20),
                recordingConfiguration: DrillRecordingConfiguration(maxShots: 3, maxSessionDelay: 3, shouldRecordAudio: true)
            )
        )
    }
}

#Preview("Ended") {
    NavigationStack {
        TournamentDetailView(
            tournament: Tournament(
                startDate: Date().addingTimeInterval(-(3600 * 48)),
                endDate: Date().addingTimeInterval(-(3600 * 24)),
                title: "3-shot competition",
                description: "   This is a simple 3 shot competition to test your basic shooting skills.\n   Upon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot.\n  Your result will be displayed to everyone on the leaderboard. You can submit only one entry for each tournament.",
                requirements: Tournament.Requirements(maxShotsCount: 3, maxTime: 20),
                recordingConfiguration: DrillRecordingConfiguration(maxShots: 3, maxSessionDelay: 3, shouldRecordAudio: true)
            )
        )
    }
}
