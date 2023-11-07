//
//  TournamentDetailView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-28.
//

import SwiftUI
import SwiftData

struct TournamentDetailView: View {
    
    // MARK: - Properties
    
    private var tournament: Tournament
    
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
    
    @Query private var tournamentEntries: [TournamentEntry]
    
    // MARK: - Init
    
    init(tournament: Tournament) {
        self.tournament = tournament
        self._tournamentEntries = Query(
            filter: #Predicate<TournamentEntry> { $0.tournamentId == tournament.id },
            sort: \TournamentEntry.date,
            order: .reverse
        )
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 16) {
            Text(tournament.title)
                .font(.system(.title, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                datesView
                requirementsView
                
                if tournament.description.isEmpty == false {
                    descriptionView
                }
            }
            
            if Date() > tournament.endDate {
                Text("Submissins closed. Tournament has ended")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            } else if tournamentEntries.isEmpty == false {
                Button(action: {
                    
                }, label: {
                    Text("View Leaderboard")
                        .frame(maxWidth: .infinity)
                        .padding()
                })
                .buttonStyle(.borderedProminent)
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
                            tournament: tournament,
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
    
    // MARK: - Private Views
    
    private var datesView: some View {
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
    }
    
    private var requirementsView: some View {
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
    }
    
    private var descriptionView: some View {
        Text(tournament.description)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
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

#Preview("With Entry") {
    NavigationStack {
        TournamentDetailView(tournament: TournamentPreviewData.mock)
            .modelContainer(TournamentPreviewData.container)
    }
}
