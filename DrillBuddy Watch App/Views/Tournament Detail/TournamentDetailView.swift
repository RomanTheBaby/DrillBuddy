//
//  TournamentDetailView.swift
//  DrillBuddy Watch App
//
//  Created by Roman on 2023-10-30.
//

import SwiftUI

// MARK: - TournamentDetailView

struct TournamentDetailView: View {
    
    // MARK: Preview
    
    @State var username: String? = nil
    var tournament: Tournament
    
    @State private var showUsernameInputModal = false
    
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
    
    // MARK: View
    
    var body: some View {
        List {
            Text(tournament.title)
                .font(.system(.title3, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Start:")
                            .fontWeight(.bold)
                        Text(tournament.startDate.formatted(.dateTime.day().month().hour().minute()))
                    }
                    
                    HStack {
                        Text("End:")
                            .fontWeight(.bold)
                        
                        if Date() > tournament.endDate {
                            Text("ended")
                                .foregroundStyle(Color.red)
                                .font(.callout)
                        } else {
                            Text(tournament.endDate.formatted(.dateTime.day().month().hour().minute()))
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Max Shots:")
                            .fontWeight(.bold)
                        Text("\(tournament.maxShotsCount == 0 ? "Unlimited" : "\(tournament.maxShotsCount)")")
                        Spacer()
                    }
                    
                    HStack {
                        Text("Time Limit:")
                            .fontWeight(.bold)
                        Text("\(tournament.requirements.maxTime == 0 ? "Unlimited" : "\(tournament.requirements.maxTime)")")
                        Spacer()
                    }
                    
                    HStack {
                        Text("Gun:")
                            .fontWeight(.bold)
                        Text(gunDescription)
                    }
                }
            }
                
            Section {
                if Date() > tournament.endDate {
                    Text("Submissins closed. Tournament has ended")
                        .foregroundStyle(Color.gray)
                } else {
                    VStack {
                        Text("Right now you cannot enter tournaments from watch. Please use other device")
                            .font(.system(.title3, weight: .bold))
                            .foregroundStyle(Color.red)
                        /*
                        if username != nil {
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
                                    .multilineTextAlignment(.center)
                                    .fontWeight(.bold)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
//                            Button {
//                                showUsernameInputModal = true
//                            } label: {
//                                Text("Add username to participate")
//                                    .multilineTextAlignment(.center)
//                                    .fontWeight(.bold)
//                                    .padding()
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .tint(Color.orange)
                        }
                        */
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
        .fullScreenCover(isPresented: $showUsernameInputModal, onDismiss: {
            username = NSUbiquitousKeyValueStore.default.username
        }, content: {
            Text("KEKKE")
        })
    }
}

// MARK: - Preview

#Preview("With username") {
    NavigationStack {
        TournamentDetailView(
            username: "username",
            tournament: TournamentPreviewData.mock
        )
    }
}

#Preview("Without username") {
    NavigationStack {
        TournamentDetailView(
            tournament: TournamentPreviewData.mock
        )
    }
}

#Preview("Ended") {
    NavigationStack {
        TournamentDetailView(
            tournament: TournamentPreviewData.mockEnded
        )
    }
}
