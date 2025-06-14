//
//  FirestoreService.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-31.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation


/// Note: Firestore is not available on watchOS and App Clip targets.
class FirestoreService {
    
    // MARK: - Private Properties
    
    private let database = Firestore.firestore()
    private let jsonEncoder = JSONEncoder()
    
    // MARK: - Public Methods
    
    func fetchTournaments() async throws -> [Tournament] {
        do {
            return try await database.collection(.tournaments).getDocuments()
                .documents
                .compactMap { tournamentDocument -> Tournament? in
                    do {
                        let tournament = try tournamentDocument.data(as: Tournament.self)
                        return tournament
                    } catch {
                        LogManager.log(.error, module: .firestoreService, message: "Failed to decode tournament wih error: \(error). Tournament data: \(tournamentDocument.data())")
                        return nil
                    }
                }
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to fetch tournaments with errror: \(error)")
            throw error
        }
    }
    
    func create(_ tournament: Tournament) async throws {
        do {
            try await database.collection(.tournaments).addDocument(from: tournament)
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to create with error: \(error)")
        }
    }
    
    func fetchLeaderboard(for tournament: Tournament) async throws -> Leaderboard {
        do {
            return try await fetchLeaderboard(withID: tournament.leaderboardID)
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to fetch leaderboard for tournament: \(tournament.id) with error: \(error)")
            throw error
        }
    }
    
    func fetchLeaderboard(withID leaderboardId: String) async throws -> Leaderboard {
        do {
            return try await database.collection(.leaderboards).document(leaderboardId).getDocument(as: Leaderboard.self)
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to fetch leaderboard by id: \(leaderboardId) with error: \(error)")
            throw error
        }
    }
    
    func submit(entry: TournamentEntry, for tournament: Tournament, as user: UserInfo) async throws {
        do {
            guard let recordingURL = entry.recordingURL else {
                throw LocalizedErrorInfo(
                    failureReason: "Missing audio file for tournament entry",
                    errorDescription: "Unable to submit tournament entry as missing audio recording.",
                    recoverySuggestion: "Please try again or contact support."
                )
            }
            
            let recordingData = try Data(contentsOf: recordingURL)
            
            let leaderboardEntry = Leaderboard.Entry(
                userId: user.id,
                username: user.username,
                recordingDate: entry.date,
                recordingData: recordingData,
                firstShotDelay: entry.sounds[0].time,
                shotsSplit: entry.sounds.averageSplit,
                totalTime: entry.sounds[entry.sounds.count - 1].time
            )
            
            do {
                let entryData = try jsonEncoder.encode(leaderboardEntry)
                let json = try JSONSerialization.jsonObject(with: entryData)
                
                do {
                    let leaderboardReference = database.collection(.leaderboards).document(tournament.leaderboardID)
                    try await leaderboardReference.updateData([
                        "entries": FieldValue.arrayUnion([json])
                    ])
                    LogManager.log(.info, module: .firestoreService, message: "Add entry to leaderboard \(tournament.leaderboardID)")
                } catch {
                    LogManager.log(.error, module: .firestoreService, message: "Failed to add leaderboard entry with error: \(error)")
                    throw error
                }
            } catch {
                LogManager.log(.error, module: .firestoreService, message: "Failed to encode leaderboard entry with error: \(error)")
                throw error
            }
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to get data from audio at \(entry.recordingURL?.absoluteString ?? "no url") with error: \(error)")
            throw error
        }
        
    }
    
    func report(entry: Leaderboard.Entry, leaderboardId: String, reporter: UserInfo) async throws {
        do {
            let leaderboardReportReferences = database.collection(.leaderboardReports).document(leaderboardId)
            
            let document = try await leaderboardReportReferences.getDocument()
            let reportData: [String: Any] = [
                entry.id: FieldValue.increment(Int64(1)),
                "reporters": FieldValue.arrayUnion([reporter.id]),
            ]
            LogManager.log(.info, module: .firestoreService, message: "Did fetch document data for leaderboard: \(leaderboardId)")
            if document.exists {
                try await leaderboardReportReferences.updateData(reportData)
            } else {
                try await leaderboardReportReferences.setData(reportData)
            }
            
            LogManager.log(.info, module: .firestoreService, message: "Did report entry: \(entry.id), on leaderboard: \(leaderboardId) by reporter: \(reporter.id)")
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to report entry: \(entry.id), on leaderboard: \(leaderboardId) with error: \(error)")
            throw error
        }
    }
    
    func addUsername(_ username: String) async throws {
        do {
            do {
                guard try await isUsernameAvailable(username) else {
                    LogManager.log(.error, module: .firestoreService, message: "Failed to insert new username \(username) because it already exists")
                    throw LocalizedErrorInfo(
                        failureReason: "Username is a already taken",
                        errorDescription: "Username is a already taken by someone else",
                        recoverySuggestion: "Choose a different username and try again"
                    )
                }

                try await database.collection(.usernames).document(username).setData([:])
            } catch {
                LogManager.log(.error, module: .firestoreService, message: "Failed to verify if username is a duplicate, before inserting, with error \(error)")
                throw error
            }
        } catch {
            LogManager.log(.error, module: .firestoreService, message: "Failed to add username \(username) with error: \(error)")
            throw error
        }
    }
    
    // TODO: Cache usernames maybe and check from cache first
    func isUsernameAvailable(_ userName: String) async throws -> Bool {
        let usernameDocuments = try await database.collection(.usernames).getDocuments().documents
        let existingUserNames = Set(usernameDocuments.map(\.documentID))
        return existingUserNames.contains(userName) == false
    }
}

// MARK: - CollectionReference + async

private extension CollectionReference {
    @discardableResult
    func addDocument<T: Encodable>(
        from value: T,
        encoder: Firestore.Encoder = Firestore.Encoder()
    ) async throws -> T {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            do {
                try addDocument(from: value, encoder: encoder) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: value)
                    }
                }
            } catch {
                LogManager.log(.trace, module: .firestoreService, message: "Failed to add document with error: \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - DocumentReference + async

private extension DocumentReference {
    @discardableResult
    func setData<T: Encodable>(
        from value: T,
        mergeFields: [Any],
        encoder: Firestore.Encoder = Firestore.Encoder()
    ) async throws -> T {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            do {
                try setData(from: value, mergeFields: mergeFields, encoder: encoder) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: value)
                    }
                }
            } catch {
                LogManager.log(.trace, module: .firestoreService, message: "Failed to set data to document with error: \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
}
