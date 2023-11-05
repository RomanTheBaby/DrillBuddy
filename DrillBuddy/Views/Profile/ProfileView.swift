//
//  ProfileView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-01.
//

import SwiftUI
import FirebaseAuth
import FirebaseAuthCombineSwift

struct ProfileView: View {
    
    @State private var error: Error?
    
    @State private var authenticationType: AuthenticationView.AuthenticationType? = nil
    private let authenticationService: AuthenticationService = AuthenticationService()
    
    @EnvironmentObject var userStorage: UserStorage
    
    var body: some View {
        Group {
            if let currentUser = userStorage.currentUser {
                VStack {
                    Spacer()
                    Text("Logged in as: \(currentUser.username)")
                        .font(.system(.title2, weight: .medium))
                    Button(action: {
                        do {
                            try authenticationService.signOut()
                        } catch {
                            self.error = error
                        }
                    }, label: {
                        Text("Sign Out")
                            .padding()
                            .frame(maxWidth: .infinity)
                    })
                }
                .padding()
            } else {
                VStack {
                    Spacer()
                    
                    Text("Sign in to view and participate in tournaments")
                        .multilineTextAlignment(.center)
                        .font(.system(.title2, weight: .medium))
                    
                    Button(action: {
                        authenticationType = .signIn
                    }, label: {
                        Text("Sign Un")
                            .frame(maxWidth: .infinity)
                            .padding()
                    })
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                        .frame(height: 16)
                    
                }
                .padding()
            }
        }
        .onChange(of: userStorage.currentUser, { _, newValue in
            if authenticationType != nil, newValue != nil {
                authenticationType = nil
            }
        })
        .errorAlert(error: $error)
        .sheet(item: $authenticationType, onDismiss: {}) { authenticationType in
            AuthenticationView(
                authenticationType: authenticationType,
                authenticationService: authenticationService
            )
        }
    }
}

// MARK: - Previews

#Preview("Logged Out") {
    ProfileView()
        .environmentObject(UserStoragePreviewData.loggedOut)
}

#Preview("Logged In") {
    ProfileView()
        .environmentObject(
            UserStoragePreviewData.loggedIn
        )
}
