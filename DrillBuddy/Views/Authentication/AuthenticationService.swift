//
//  AuthenticationService.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-01.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import OSLog

// MARK: - AuthenticationService

class AuthenticationService {
    
    // MARK: - Properties
    
    private let firestoreService: FirestoreService
    
    // MARK: - Init
    
    init(firestoreService: FirestoreService = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    // MARK: - Public Methods
    
    @discardableResult
    func signIn(with email: String, password: String) async throws -> UserInfo {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return UserInfo(firebaseUser: authDataResult.user)
        } catch {
            Logger.authenticationService.error("Failed to sign in with error: \(error)")
            
            // So Google's response structure is weird.
            // Actual error can be an underlying error or it may not be,
            // error.code is internal error, when message says invalid_credentials. Fucking morons
            if let underlyingError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError,
               let underlyingErrorInfo = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any],
               let message = underlyingErrorInfo["message"] as? String {
                throw LocalizedErrorInfo(failureReason: message, errorDescription: "Auth Error")
            }
        
            throw error
        }
    }
    
    @discardableResult
    func createUser(username: String, email: String, password: String) async throws -> UserInfo {
        do {
            guard try await firestoreService.isUsernameAvailable(username) else {
                throw LocalizedErrorInfo(
                    failureReason: "Username already taken",
                    errorDescription: "Someone else already has that username",
                    recoverySuggestion: "Please select other username and try again"
                )
            }
            
            do {
                let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
                do {
                    try await updateUsername(for: authDataResult.user, to: username)
                    
                    try? await firestoreService.addUsername(username)
                    
                    return UserInfo(
                        id: authDataResult.user.uid,
                        username: username,
                        email: authDataResult.user.email ?? ""
                    )
                } catch {
                    Logger.authenticationService.error("Failed to update username with error: \(error)")
                    return UserInfo(firebaseUser: authDataResult.user)
                }
            } catch {
                Logger.authenticationService.error("Failed to sign up with error: \(error)")
                throw error
            }
        } catch {
            Logger.authenticationService.error("Failed to validate usernames with error: \(error)")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            Logger.authenticationService.error("Failed to log out with error: \(error)")
        }
    }
    
    // MARK: Private Methods
    
    private func updateUsername(for user: FirebaseAuth.User, to newUsername: String) async throws {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newUsername
        try await changeRequest.commitChanges()
    }
}

// MARK: - Logger

private extension Logger {
    static let authenticationService = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.AuthenticationService",
        category: String(describing: AuthenticationService.self)
    )
}
