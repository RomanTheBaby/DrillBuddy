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
    
    private let user: UserInfo
    private let firestoreService: FirestoreService
    
    /// Holds entries to given tournament
    /// NOTE: We cannot have custom query initialization within the `init` sequence,
    /// as for some reason, when we do that navigation link stop working
    private let tournamentEntries: [TournamentEntry]
    
    @State private var leaderboard: Leaderboard? = nil
    @State private var isLoadingData: Bool = false
    
    @State private var presentableLeaderboard: Leaderboard?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var leaderboardUpdateError: Error?
    @State private var entrySubmissionError: Error?
    
    // MARK: - Init
    
    init(
        tournament: Tournament,
        leaderboard: Leaderboard? = nil,
        tournamentEntries: [TournamentEntry] = [],
        user: UserInfo,
        firestoreService: FirestoreService = FirestoreService()
    ) {
        self.tournament = tournament
        self.firestoreService = firestoreService
        self._leaderboard = State(initialValue: leaderboard)
        self.tournamentEntries = tournamentEntries
        self.user = user
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
            
            expiredTournamentDisclaimerView
            
            if leaderboard == nil || isLoadingData {
                ProgressView()
                    .progressViewStyle(.circular)
            } else if let leaderboard {
                if leaderboard.containsEntry(from: user) {
                    Button(action: {
                        presentableLeaderboard = leaderboard
                    }, label: {
                        Text("View Leaderboard")
                            .frame(maxWidth: .infinity)
                            .padding()
                    })
                    .buttonStyle(.borderedProminent)
                } else if let tournamentEntry = tournamentEntries.first {
                    VStack {
                        Text("You already have your attempt. Submit it to view this tournament leaderboard")
                            .fontWeight(.medium)
                            .foregroundStyle(Color.red)
                        Button(action: {
                            Task {
                                await submit(tournamentEntry: tournamentEntry, to: leaderboard)
                            }
                        }, label: {
                            Text("Submit Entry")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.borderedProminent)
                    }
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .alert("Failed to fetch leaderboard", isPresented: Binding<Bool>(get: {
            leaderboardUpdateError != nil
        }, set: { value in
            if value == false {
                leaderboardUpdateError = nil
            }
        }), actions: {
            if leaderboard == nil {
                Button("Exit", role: .cancel, action: {
                    dismiss()
                })
            }

            Button("Retry", role: .destructive, action: {
                Task {
                    await updateLeaderboard()
                }
            })
        }, message: {
            Text(leaderboardUpdateError?.localizedDescription ?? "An error occured during leaderboard update")
        })
        .alert("Failed to submit entry to leaderboard", isPresented: Binding<Bool>(get: {
            entrySubmissionError != nil
        }, set: { value in
            if value == false {
                entrySubmissionError = nil
            }
        }), actions: {
            Button("Retry", role: .destructive, action: {
                Task {
                    await submit(tournamentEntry: tournamentEntries[0], to: leaderboard!)
                }
            })
        }, message: {
            Text(leaderboardUpdateError?.localizedDescription ?? "An error occured during leaderboard update")
        })
        .sheet(item: $presentableLeaderboard, content: { leaderboard in
            LeaderboardView(leaderboard: leaderboard, searchableUserId: user.id)
        })
        .task {
            await updateLeaderboard()
        }
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
    
    private var expiredTournamentDisclaimerView: some View {
        Group {
            if Date() > tournament.endDate {
                Text("Submissins closed. Tournament has ended")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateLeaderboard() async {
        isLoadingData = true
        do {
            self.leaderboard = try await firestoreService.fetchLeaderboard(for: tournament)
        } catch {
            leaderboardUpdateError = error
        }
        isLoadingData = false
    }
    
    private func submit(tournamentEntry: TournamentEntry, to leaderboard: Leaderboard) async {
        isLoadingData = true
        do {
            try await firestoreService.submit(entry: tournamentEntry, for: tournament, as: user)
            do {
                self.leaderboard = try await firestoreService.fetchLeaderboard(for: tournament)
            } catch {
                let recordingData = try! Data(contentsOf: tournamentEntry.recordingURL)
                
                let leaderboardEntry = Leaderboard.Entry(
                    userId: user.id,
                    username: user.username,
                    recordingDate: tournamentEntry.date,
                    recordingData: recordingData,
                    firstShotDelay: tournamentEntry.sounds[0].time,
                    shotsSplit: tournamentEntry.sounds.averageSplit,
                    totalTime: tournamentEntry.sounds[tournamentEntry.sounds.count - 1].time
                )
                
                self.leaderboard = Leaderboard(
                    id: leaderboard.id,
                    entries: leaderboard.entries + [leaderboardEntry],
                    tournamentID: leaderboard.tournamentID
                )
            }
        } catch {
            entrySubmissionError = error
        }
        isLoadingData = false
    }
}

// MARK: - Preview

#Preview("Newcommer") {
    NavigationStack {
        TournamentDetailView(
            tournament: TournamentPreviewData.mock,
            user: UserStoragePreviewData.loggedIn.currentUser!
        )
    }
}

#Preview("Ended") {
    NavigationStack {
        TournamentDetailView(
            tournament: TournamentPreviewData.mockEnded,
            user: UserStoragePreviewData.loggedIn.currentUser!
        )
    }
}

#Preview("With Unsubmitted Entry") {
    NavigationStack {
        TournamentDetailView(
            tournament: TournamentPreviewData.mock,
            leaderboard: Leaderboard(
                id: TournamentPreviewData.mock.leaderboardID,
                entries: [],
                tournamentID: TournamentPreviewData.mock.id
            ),
            tournamentEntries: [TournamentPreviewData.mockEntry],
            user: UserStoragePreviewData.loggedIn.currentUser!
        )
        .modelContainer(TournamentPreviewData.container)
    }
}

#Preview("With Submitted Entry") {
    NavigationStack {
        TournamentDetailView(
            tournament: TournamentPreviewData.mock,
            leaderboard: Leaderboard(
                id: TournamentPreviewData.mock.leaderboardID,
                entries: [
                    Leaderboard.Entry(
                        userId: UserStoragePreviewData.loggedIn.currentUser!.id,
                        username: UserStoragePreviewData.loggedIn.currentUser!.username,
                        recordingDate: Date(),
                        recordingData: Data(),
                        firstShotDelay: 0.5,
                        shotsSplit: 1.2,
                        totalTime: 4
                    )
                ],
                tournamentID: TournamentPreviewData.mock.id
            ),
            tournamentEntries: [TournamentPreviewData.mockEntry],
            user: UserStoragePreviewData.loggedIn.currentUser!
        )
        .modelContainer(TournamentPreviewData.container)
    }
}
