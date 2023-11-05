//
//  FirestoreService.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-31.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import OSLog


/// Note: Firestore is not available on watchOS and App Clip targets.
class FirestoreService {
    
    // MARK: - Private Properties
    
    private let database = Firestore.firestore()
    
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
                        Logger.firestoreService.error("Failed to decode tournament wih error: \(error). Tournament data: \(tournamentDocument.data())")
                        return nil
                    }
                }
        } catch {
            Logger.firestoreService.error("Failed to fetch tournaments with errror: \(error)")
            throw error
        }
    }
    
    func create(_ tournament: Tournament) async throws {
        do {
            try await database.collection(.tournaments).addDocument(from: tournament)
        } catch {
            Logger.firestoreService.error("Failed to create with error: \(error)")
        }
    }
    
    func addUsername(_ username: String) async throws -> Bool {
        do {
            let usernameDocuments = try await fetchUsernames()
            
            let isUsernameDuplicate = usernameDocuments.map(\.documentID).contains(username)
            guard isUsernameDuplicate == false else {
                throw LocalizedErrorInfo(
                    failureReason: "Username is a already taken",
                    errorDescription: "Username is a already taken by someone else",
                    recoverySuggestion: "Choose a different username and try again"
                )
            }
            try await database.collection(.usernames).document(username).setData([:])
            return true
        } catch {
            Logger.firestoreService.error("Failed to add username \(username) with error: \(error)")
            throw error
        }
    }
    
    private func fetchUsernames() async throws -> [QueryDocumentSnapshot] {
        return try await database.collection(.usernames).getDocuments().documents
    }
}

// MARK: - CollectionReference + async

extension CollectionReference {
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
                Logger.firestoreService.trace("Failed to add document")
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Logger

private extension Logger {
    static let firestoreService = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.FirestoreService",
        category: String(describing: FirestoreService.self)
    )
}
