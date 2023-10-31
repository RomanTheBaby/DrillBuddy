//
//  TournamentDetailView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-28.
//

import SwiftUI

struct TournamentDetailView: View {
    
    var tournament: Tournament
    
    private var gunDescription: String {
        let gunType = tournament.requirements.gunType
        let gunActionType = tournament.requirements.gunActionType
        switch gunActionType {
        case .any:
            return gunType.description
        case .lever, .pump, .semiAuto:
            return "\(gunType.description) \(gunActionType.description)"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(tournament.title)
                .font(.system(.title, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Start:")
                        .fontWeight(.medium)
                    Text(tournament.startDate.formatted(.dateTime.day().month().hour().minute()))
                    Spacer()
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
                    Spacer()
                }
            }
            .frame(width: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
                
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
                }
                
                HStack {
                    Text("Gun:")
                        .fontWeight(.medium)
                    Text(gunDescription)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
            
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
                requirements: Tournament.Requirements(gunActionType: .semiAuto, maxShotsCount: 3, maxTime: 20),
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
