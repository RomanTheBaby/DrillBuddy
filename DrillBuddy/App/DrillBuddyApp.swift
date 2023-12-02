//
//  DrillBuddyApp.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

#if os(iOS)
import FirebaseCore
#endif
import SwiftUI
import SwiftData

#if os(macOS)
#endif
#if os(iOS)
#endif
                
#if os(watchOS)
#else
#endif

#if os(iOS)
// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
#endif

// TODO: update date parsing for tournaments from server???
// TODO: find most optimal/accurate configuration params
// TODO: improve audio visualization(i.e like telegram or other way to show waves)
// TODO: better communicate errors on DrillRecordingView
// TODO: Add DrillDetailView for watch target, maybe vertical tabs like workout app???
// TODO: implements statistics, to communicate improvements in drill to users???
// TODO: play timer sound when starting drill(transition from standby to recording). And haptic feedback(always haptic feedback on watch)
// TODO: when syncing watch data to phone find a better way to transfer audio file(i.e trafter file data instead). URL seems to work tho
@main
struct DrillBuddyApp: App {
    
    #if !os(watchOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userStorage = UserStorage()
    #endif
    
    
    var body: some Scene {
        #if !targetEnvironment(simulator)
        let modelContainer = ModelContainer.shared
        #elseif os(watchOS)
        let modelContainer = DrillSessionsContainerSampleData.container
        #else
        let modelContainer = ModelContainer.temporary
        #endif
        
        return WindowGroup {
            MainTabView(
                watchDataSynchronizer: WatchDataSynchronizer(modelContext: ModelContext(modelContainer))
            )
            #if !os(watchOS)
            .environmentObject(userStorage)
            #endif
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - ModelContainer

private extension ModelContainer {
//    static let shared = try! ModelContainer(
//        for: ShootingSession.self,
//        configurations: ModelConfiguration("DrillBuddyRecords", groupContainer: .identifier("group.bakehouse.drillbuddy"))
//    )
    
    static let temporary: ModelContainer = {
        let schema = Schema([
            DrillsSessionsContainer.self,
            TournamentEntry.self,
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
            TournamentEntry.self,
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
