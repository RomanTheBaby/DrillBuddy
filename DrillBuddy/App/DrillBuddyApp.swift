//
//  DrillBuddyApp.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import SwiftUI
import SwiftData

#if os(macOS)
#endif
#if os(iOS)
#endif
                
#if os(watchOS)
#else
#endif
                
@main
struct DrillBuddyApp: App {
    
    var body: some Scene {
        #if os(watchOS)
        let modelContainer = DrillSessionsContainerSampleData.container
        #else
        let modelContainer = ModelContainer.temporary
        #endif
        
        return WindowGroup {
            NavigationStack {
                SessionsListView(
                    watchDataSynchronizer: WatchDataSynchronizer(modelContext: ModelContext(modelContainer))
                )
            }
        }
        .modelContainer(modelContainer)
    }
}

private extension ModelContainer {
//    static let shared = try! ModelContainer(
//        for: ShootingSession.self,
//        configurations: ModelConfiguration("DrillBuddyRecords", groupContainer: .identifier("group.bakehouse.drillbuddy"))
//    )
    
    static let temporary: ModelContainer = {
        let schema = Schema([
            DrillsSessionsContainer.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    static let shared: ModelContainer = {
        let schema = Schema([
            DrillsSessionsContainer.self,
        ])
        // TODO: - specify group id???
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
