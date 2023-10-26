//
//  DrillListTabView.swift
//  DrillBuddy Watch App
//
//  Created by Roman on 2023-09-23.
//

import AVFoundation
import SwiftUI
import SwiftData

struct SessionsListView: View {
    // MARK: - Tab
    
    enum Tab {
        case controls
        case recordslist
        
        var title: String {
            switch self {
            case .controls:
                return "Controls"
            case .recordslist:
                return "List"
            }
        }
    }

    // MARK: - Public Properties
    
    @StateObject var watchDataSynchronizer: WatchDataSynchronizer
    @State var selectedTab: Tab = .controls
    var customNewSessionAction: (() -> Void)? = nil
    
    // MARK: - Private Properties
    
    @Query(sort: \DrillsSessionsContainer.date, order: .reverse)
    private var drillContainers: [DrillsSessionsContainer]
    
    @State private var error: Error?
    @State private var isSynchronizing: Bool = false
    @State private var redirectToNewDrillConfigurationView = false
    @State private var isConfirmingDeletion = false
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    // MARK: - View
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                if drillContainers.isEmpty {
                    emptyView
                } else {
                    sessionsListView
                }
            }
            .tabItem { Text(Tab.recordslist.title) }
            .tag(Tab.recordslist)
            
            controlsView
                .tabItem { Text(Tab.controls.title) }
                .tag(Tab.controls)
        }
        .errorAlert(error: $error)
        .navigationDestination(isPresented: $redirectToNewDrillConfigurationView) {
            DrillConfigurationView()
        }
        .onChange(of: drillContainers) { _, newValue in
            if newValue.isEmpty {
                selectedTab = .controls
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete ALL records?",
            isPresented: $isConfirmingDeletion) {
                
                Button("Delete", role: .destructive) {
                    deleteAllRecords()
                }
                
                Button("Cancel", role: .cancel) {
                    isConfirmingDeletion = false
                }
            } message: {
                Text("This action cannot be undone")
            }
    }
    
    private var sessionsListView: some View {
        List {
            ForEach(drillContainers, id: \.date) { container in
                Section {
                    ForEach(Array(container.drills.enumerated()), id: \.offset) { index, drill in
                        HStack {
                            Text("Drill #\(index + 1)")
                            Spacer()
                            if drill.recordingURL != nil {
                                Image(systemName: "speaker.3.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color.orange)
                            }
                        }
                    }
                } header: {
                    Text(container.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 12)
                }
                .headerProminence(.increased)
            }
        }
        .toolbar {
//            //            ToolbarItemGroup(placement: .primaryAction) {
//            //                            ToolbarItem(placement: .navigationBarTrailing) {
////            ToolbarItem(placement: .bottomBar) {
////            ToolbarItem(placement: .topBarLeading) {
////                ToolbarItem {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    redirectToNewDrillConfigurationIfNeeded()
                } label: {
                    Label("Add New", systemImage: "plus")
                        .labelsHidden()
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private var emptyView: some View {
        VStack {
            Text("All data is synced with phone...")
                .multilineTextAlignment(.center)
                .font(.system(.title3, weight: .medium))
            
            Spacer()
            
            Button(action: {
                redirectToNewDrillConfigurationIfNeeded()
            }) {
                Label("Add New", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .tint(Color.orange)
        }
    }
    
    private var controlsView: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        print("Delete all is not implemented yet.Need:\n1. Confirmation popup?\n2.Delete functionality")
                        isConfirmingDeletion = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(Color.red)
                    Text("Clear Data")
                }
                .disabled(drillContainers.isEmpty || isSynchronizing)
                
                VStack {
                    Button {
                        Task {
                            await synchronizeContainers()
                        }
                    } label: {
                        if isSynchronizing {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .fixedSize(horizontal: true, vertical: true)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .tint(Color.yellow)
                    Text("Sync Data")
                }
                .disabled(isSynchronizing || drillContainers.isEmpty)
            }
            
            HStack {
                VStack {
                    Button {
                        if let customNewSessionAction {
                            customNewSessionAction()
                        } else {
                            redirectToNewDrillConfigurationIfNeeded()
                        }
                    } label: {
                        Label("Start New", systemImage: "plus")
                    }
                    .tint(Color.green)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func redirectToNewDrillConfigurationIfNeeded(failInPreview: Bool = false) {
        if isInPreview {
            if failInPreview {
                error = AppError.Microphone.noAccessPreview
            } else {
                redirectToNewDrillConfigurationView = true
            }
        } else {
            do {
                try ensureMicrophoneAccess()
                redirectToNewDrillConfigurationView = true
            } catch let microphoneError {
                error = microphoneError
                redirectToNewDrillConfigurationView = false
            }
        }
    }
    
    private func ensureMicrophoneAccess() throws {
        switch AVAudioApplication.shared.recordPermission {
        case .denied:
            throw AppError.Microphone.noAccess
        case .granted:
            break
        case .undetermined:
            var hasMicrophoneAccess = false

            let sem = DispatchSemaphore(value: 0)
            
            AVAudioApplication.requestRecordPermission { hasPermission in
                hasMicrophoneAccess = hasPermission
                sem.signal()
            }
            
            if !hasMicrophoneAccess {
                throw AppError.Microphone.noAccess
            }
        @unknown default:
            assertionFailure("unknown authorization status for watch microphone access: \(AVAudioApplication.shared.recordPermission)")
            throw AppError.Microphone.noAccess
        }
    }
    
    private func synchronizeContainers() async {
        do {
            isSynchronizing = true
            try await watchDataSynchronizer.synchronize(drillContainers)
            isSynchronizing = false
        } catch let syncError {
            isSynchronizing = false
            error = syncError
        }
    }
    
    private func deleteAllRecords() {
        modelContext.container.deleteAllData()
    }
}

// MARK: - Previews

#Preview("With Data") {
    MainActor.assumeIsolated {
        NavigationStack {
            SessionsListView(
                watchDataSynchronizer: WatchDataSynchronizer(
                    modelContext: DrillSessionsContainerSampleData.container.mainContext
                ),
                selectedTab: .recordslist
            )
            .modelContainer(DrillSessionsContainerSampleData.container)
        }
    }
}

#Preview("No Data") {
    NavigationStack {
        SessionsListView(
            watchDataSynchronizer: WatchDataSynchronizer(
                modelContext: DrillSessionsContainerSampleData.container.mainContext
            )
        )
    }
}
