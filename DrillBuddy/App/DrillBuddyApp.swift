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
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainer.shared)
    }
}

private extension ModelContainer {
//    static let shared = try! ModelContainer(
//        for: ShootingSession.self,
//        configurations: ModelConfiguration("DrillBuddyRecords", groupContainer: .identifier("group.bakehouse.drillbuddy"))
//    )
    
    static let shared: ModelContainer = {
        let schema = Schema([
            DrillsSessionsContainer.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
