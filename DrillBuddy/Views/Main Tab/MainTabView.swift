//
//  MainTabView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-01.
//

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
    
    @StateObject var watchDataSynchronizer: WatchDataSynchronizer
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            TabView {
                ForEach(Tab.allCases, id: \.title) { tab in
                    makeView(for: tab)
                        .modelContext(modelContext)
                }
            }
        }
    }
    
    private func makeView(for tab: Tab) -> some View {
        switch tab {
        case .drills:
            return AnyView(
                NavigationStack {
                    SessionsListView(watchDataSynchronizer: watchDataSynchronizer)
                }.tabItem {
                    tab.label
                }.tag(tab)
            )
        case .tournaments:
            return AnyView(
                NavigationStack {
                    TournamentsListView()
                }.tabItem {
                    tab.label
                }.tag(tab)
            )
        case .account:
            return AnyView(
                NavigationStack {
                    ProfileView()
                }.tabItem {
                    tab.label
                }.tag(tab)
            )
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
