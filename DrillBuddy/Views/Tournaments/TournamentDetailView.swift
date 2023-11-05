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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
                
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Max Shots:")
                        .fontWeight(.medium)
                    Text("\(tournament.maxShotsCount == 0 ? "Unlimited" : "\(tournament.maxShotsCount)")")
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
            
            ScrollView {
                Text(tournament.description)
                    .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
            
            if Date() > tournament.endDate {
                Text("Submissins closed. Tournament has ended")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            } else {
                Text("Leaderboard will be available after submission")
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                
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
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        
    }
}

// MARK: - Preview

#Preview("Normal") {
    NavigationStack {
        TournamentDetailView(tournament: TournamentPreviewData.mock)
    }
}

#Preview("Ended") {
    NavigationStack {
        TournamentDetailView(tournament: TournamentPreviewData.mockEnded)
    }
}
