//
//  MainTabView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-01.
//

import FirebaseRemoteConfig
import SwiftUI
import SwiftData

struct MainTabView: View {
    
    // MARK: - Tab
    
    enum Tab: CaseIterable {
        case drills
        case tournaments
        case account
        
        var title: String {
            switch self {
            case .drills:
                return "Drills"
            case .tournaments:
                return "Tournaments"
            case .account:
                return "Account"
            }
        }
        
        fileprivate var label: some View {
            switch self {
            case .drills:
                return Label(title, systemImage: "list.dash")
            case .tournaments:
                return Label(title, systemImage: "suit.club.fill")
            case .account:
                return Label(title, systemImage: "person.fill")
            }
        }
    }
    
    @State private var selectedTab: Tab = .drills
    @State private var configuration: AppRemoteConfig.MainTabBar? = nil
    
    @StateObject var watchDataSynchronizer: WatchDataSynchronizer
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    var body: some View {
        if let configuration {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    ForEach(tabs(for: configuration), id: \.title) { tab in
                        makeView(for: tab)
                            .toolbar(tabs(for: configuration).count > 1 ? .visible : .hidden, for: .tabBar)
                    }
                }
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
                .task {
                    await startFetching()
                }
        }
    }
    
    private func tabs(for configuration: AppRemoteConfig.MainTabBar) -> [Tab] {
        Tab.allCases.filter { tab in
            switch tab {
            case .drills:
                return true
            case .tournaments:
                return configuration.showTournaments
            case .account:
                return configuration.showSettings
            }
        }
    }
    
    private func makeView(for tab: Tab) -> some View {
        switch tab {
        case .drills:
            return AnyView(
                NavigationStack {
                    SessionsListView(watchDataSynchronizer: watchDataSynchronizer)
                        .modelContext(modelContext)
                }.tabItem {
                    tab.label
                }.tag(tab)
            )
        case .tournaments:
            return AnyView(
                NavigationStack {
                    TournamentsListView()
                        .modelContext(modelContext)
                }.tabItem {
                    tab.label
                }.tag(tab)
            )
        case .account:
            return AnyView(
                NavigationStack {
                    ProfileView()
                        .modelContext(modelContext)
                }.tabItem {
                    tab.label
                }.tag(tab)
            )
        }
    }
    
    private func startFetching() async {
        do {
            let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                do {
                    let configData = RemoteConfig.remoteConfig().configValue(forKey: String(describing: AppRemoteConfig.self))
                    configuration = try JSONDecoder().decode(AppRemoteConfig.self, from: configData.dataValue).mainTabBar
                } catch {
                    LogManager.log(.fault, module: .mainTabView, message: "Failed to decode remote config with error \(error)")
                    configuration = AppRemoteConfig.default.mainTabBar
                }
            default:
                configuration = AppRemoteConfig.default.mainTabBar
            }
        } catch let error {
            LogManager.log(.fault, module: .mainTabView, message: "Failed to fetch remote config with error: \(error)")
            configuration = AppRemoteConfig.default.mainTabBar
        }
    }
}

// MARK: - Previews

#Preview("Logged in") {
    MainTabView(
        watchDataSynchronizer: WatchDataSynchronizer(
            modelContext: DrillSessionsContainerSampleData.container.mainContext
        )
    )
    .environmentObject(UserStoragePreviewData.loggedIn)
}

#Preview("Logged Out") {
    MainTabView(
        watchDataSynchronizer: WatchDataSynchronizer(
            modelContext: DrillSessionsContainerSampleData.container.mainContext
        )
    )
    .environmentObject(UserStoragePreviewData.loggedIn)
}
