//
//  TournamentsListView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-28.
//

import SwiftUI
import SwiftData

// MARK: - TournamentsListView

struct TournamentsListView: View {
    
    @State var tournaments: [Tournament] = []
    
    @State private var error: Error? = nil
    @State private var isLoading: Bool = false
    @State private var selectedTournament: Tournament?
    @State private var authenticationType: AuthenticationView.AuthenticationType? = nil
    
    var firestoreService: FirestoreService = FirestoreService()
    
    @EnvironmentObject private var userStorage: UserStorage
    
    @Query(sort: \TournamentEntry.date, order: .forward)
    private var tournamentEntries: [TournamentEntry]

    var body: some View {
        Group {
            if let user = userStorage.currentUser {
                makeTournamentsView(for: user)
                    .navigationTitle("Tournments")
                    .errorAlert(error: $error)
                    .task {
                        await loadTournaments()
                    }
            } else {
                anonymousView
            }
        }
        .onChange(of: userStorage.currentUser, { _, newValue in
            if authenticationType != nil, newValue != nil {
                authenticationType = nil
            }
        })
        .sheet(item: $authenticationType, onDismiss: {}) { authenticationType in
            AuthenticationView(authenticationType: authenticationType)
        }
    }
    
    private var anonymousView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("To View and participate in tournaments please log in")
                .multilineTextAlignment(.center)
                .font(.system(.title2, weight: .medium))
            
            Button(action: {
                authenticationType = .signIn
            }, label: {
                Text("Log In")
                    .padding()
            })
            .buttonStyle(.borderedProminent)
            
            Spacer()
                .frame(height: 56)
        }
        .padding()
    }
    
    private func makeTournamentsView(for user: UserInfo) -> some View {
        Group {
            if tournaments.isEmpty {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading tournaments...")
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Currently there are no tournaments. Check back later")
                            .multilineTextAlignment(.center)
                            .fontWeight(.medium)
                        Button(action: {
                            Task {
                                await loadTournaments(showLoadingIndicator: true)
                            }
                        }, label: {
                            Text("Retry")
                        })
                    }
                }
            } else {
                List {
                    ForEach(tournaments) { tournament in
                        TournamentCardView(tournament: tournament)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTournament = tournament
                            }
                            #if !os(watchOS)
                            .listRowSeparator(.hidden)
                            #endif
                    }
                }
                .fullScreenCover(item: $selectedTournament, content: { tournament in
                    NavigationStack {
                        TournamentDetailView(
                            tournament: tournament,
                            tournamentEntries: tournamentEntries(for: tournament),
                            user: user
                        )
                    }
                })
                #if !os(watchOS)
                .listRowSpacing(16)
                #endif
                .navigationTitle("Tournaments")
                .navigationBarTitleDisplayMode(.large)
                .refreshable {
                    await loadTournaments(showLoadingIndicator: false)
                }
            }
        }
    }
    
    private func loadTournaments(showLoadingIndicator: Bool = true) async {
        guard isLoading == false else {
            return
        }
        
        do {
            isLoading = showLoadingIndicator ? true : false
            if isInPreview == false {
                tournaments = try await firestoreService.fetchTournaments()
                    .filter {
                        $0.isHidden == false
                    }
            }
            isLoading = false
        } catch let fetchError {
            isLoading = false
            error = fetchError
        }
    }
    
    private func tournamentEntries(for tournament: Tournament) -> [TournamentEntry] {
        guard let currentUser = userStorage.currentUser else {
            return []
        }
        
        return tournamentEntries.filter { entry in
            entry.tournamentId == tournament.id && entry.userId == currentUser.id
        }
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
                Text("\(tournament.maxShotsCount) shot(s)")
                Spacer()
                HStack {
                    Text(timeText)
                    Image(systemName: "timer")
                }
            }
        }
    }
}

// MARK: - Data Helper

private extension Date {
    var tournamentFormatted: String {
        self.formatted(.dateTime.day().month())
    }
}

#if DEBUG
// MARK: - Previews

#Preview("Tournaments") {
    NavigationStack {
        TournamentsListView(
            tournaments: [
                Tournament(
                    id: UUID().uuidString,
                    startDate: Date().addingTimeInterval(-(3600 * 48)),
                    endDate: Date().addingTimeInterval(-(3600 * 24)),
                    isHidden: false,
                    title: "3-shot competition",
                    description: "",
                    leaderboardID: UUID().uuidString,
                    requirements: Tournament.Requirements(maxTime: 20),
                    recordingConfiguration: DrillRecordingConfiguration(maxShots: 3, maxSessionDelay: 4, shouldRecordAudio: true)
                ),
                Tournament(
                    id: UUID().uuidString,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(3600 * 24),
                    isHidden: false,
                    title: "3-shot competition",
                    description: "This is a simple 3 shot competition to test your basic shooting skills.\nUpon starting the drill draw your weapon and make 3 shots, drill recording will automatically stop when app will hear 3rd shot",
                    leaderboardID: UUID().uuidString,
                    requirements: Tournament.Requirements(maxTime: 0),
                    recordingConfiguration: DrillRecordingConfiguration(maxShots: 3, maxSessionDelay: 4, shouldRecordAudio: true)
                )
            ]
        )
        .environmentObject(
            UserStorage(
                userInfo: UserInfo(id: "", username: "user_name", email: "email@em.com"),
                listenToAuthStateChanges: false
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        TournamentsListView(tournaments: [])
            .environmentObject(UserStoragePreviewData.loggedIn)
    }
    .modelContainer(TournamentPreviewData.container)
}

#Preview("Logged Out") {
    NavigationStack {
        TournamentsListView(tournaments: [])
            .environmentObject(UserStoragePreviewData.loggedOut)
    }
}
#endif
