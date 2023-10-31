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

// TODO: Add tournaments tab on main screen
// TODO: Create basic 3 shot tournament
// TODO: Use leaderboards from GameKit for tournament??????
// TODO: find most optimal/accurate configuration params
// TODO: improve audio visualization(i.e like telegram or other way to show waves)
// TODO: Add information popups on drill configuration parameters(user taps `i` button, pop up shows that explains what this parameters means)
// TODO: better communicate errors on DrillRecordingView
// TODO: Add DrillDetailView for watch target, maybe vertical tabs like workout app???
// TODO: implements statistics, to communicate improvements in drill to users???
// TODO: play timer sound when starting drill(transition from standby to recording). And haptic feedback(always haptic feedback on watch)
// TODO: when syncing watch data to phone find a better way to transfer audio file(i.e trafter file data instead). URL seems to work tho
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
        .modelContainer(ModelContainer.temporary)
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
