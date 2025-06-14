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
    
    @Environment(\.remoteConfiguration)
    private var remoteConfiguration: AppRemoteConfig
    
    @State private var authenticationType: AuthenticationView.AuthenticationType? = nil
    private let authenticationService: AuthenticationService = AuthenticationService()
    
    @EnvironmentObject var userStorage: UserStorage
    
    var body: some View {
        contentView
            .navigationTitle("Settings")
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
    
    @ViewBuilder
    private var contentView: some View {
        if let currentUser = userStorage.currentUser {
            VStack {
                Text("Welcome, **\(currentUser.username)**")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
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
            List {
                if remoteConfiguration.settingsTab.showLogInButton {
                    VStack {
                        Text("Sign in to view and participate in tournaments")
                            .multilineTextAlignment(.leading)
                            .font(.system(.title3, weight: .medium))
                        
                        Button(action: {
                            authenticationType = .signIn
                        }, label: {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding(4)
                        })
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(2)
                    .frame(maxWidth: .infinity)
                }
                Link("Leave a review", destination: URL(string: "https://apps.apple.com/us/app/drillbuddy/id6473848506")!)
            }
        }
    }
}

#if DEBUG

// MARK: - Previews

#Preview("Logged Out - No login button") {
    NavigationStack {
        ProfileView()
            .environmentObject(UserStoragePreviewData.loggedOut)
            .environment(
                \.remoteConfiguration,
                 AppRemoteConfig(
                    mainTabBar: AppRemoteConfig.MainTabBar(showSettings: true, showTournaments: false),
                    settingsTab: AppRemoteConfig.SettingsTab(showLogInButton: false)
                 )
            )
    }
}

#Preview("Logged Out ") {
    NavigationStack {
        ProfileView()
            .environmentObject(UserStoragePreviewData.loggedOut)
            .environment(
                \.remoteConfiguration,
                 AppRemoteConfig(
                    mainTabBar: AppRemoteConfig.MainTabBar(showSettings: true, showTournaments: false),
                    settingsTab: AppRemoteConfig.SettingsTab(showLogInButton: true)
                 )
            )
    }
}

#Preview("Logged In") {
    NavigationStack {
        ProfileView()
            .environmentObject(
                UserStoragePreviewData.loggedIn
            )
    }
}

#endif
