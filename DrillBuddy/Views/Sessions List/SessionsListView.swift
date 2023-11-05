//
//  SessionsListView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import AVFoundation
import OSLog
import SwiftUI
import SwiftData

struct SessionsListView: View {

    // MARK: - Constants
    
    private enum Constants {
        static let newSessionButton: CGSize = CGSize(
            width: 90,
            height: 90
        )
    }
    
    // MARK: - Public Properties
    
    @StateObject var watchDataSynchronizer: WatchDataSynchronizer
    
    // MARK: - Private Properties
    
    @State private var error: Error?
    @State private var hasMicrophoneAccess = true
    @State private var isPresentingDeleteDataAlert: Bool = false
    @State private var redirectToNewDrillConfigurationView = false
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    @Query(sort: \DrillsSessionsContainer.date, order: .reverse, animation: .smooth)
    private var drillContainers: [DrillsSessionsContainer]
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            Group {
                if drillContainers.isEmpty {
                    emptyView
                } else {
                    listView
                        .navigationTitle("My Sessions")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
            .fullScreenCover(isPresented: $redirectToNewDrillConfigurationView, content: {
                NavigationStack {
                    DrillConfigurationView()
                }
            })
            .confirmationDialog(
                "Confirm Action",
                isPresented: $isPresentingDeleteDataAlert
            ) {
                Button("Delete All", role: .destructive, action: clearData)
            } message: {
                Text("Are you sure you want to delete all records?\nThis action cannot be undone")
            }
        }
        .errorAlert(error: $error)
    }
    
    private var emptyView: some View {
        VStack {
            Text("You do not have any drills yet...")
                .multilineTextAlignment(.center)
                .font(.system(.title2, weight: .bold))
            Button(action: {
                redirectToNewDrillConfigurationIfNeeded()
            }) {
                Label("Add New", systemImage: "plus")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            #if os(watchOS)
            .tint(Color.orange)
            #else
            .tint(Color.blue)
            #endif
        }
    }
    
    private var listView: some View {
        List {
            ForEach(drillContainers, id: \.date) { container in
                Section {
                    ForEach(Array(container.drills.enumerated()), id: \.offset) { index, drill in
                        NavigationLink(destination: DrillDetailView(drill: drill)) {
                            HStack {
                                Text("Drill #\(index + 1)")
                                Spacer()
                                if drill.recordingURL != nil {
                                    Image(systemName: "speaker.3.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(Color.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Text(container.title)
                        .font(.title2)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 12)
                }
                .headerProminence(.increased)
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isPresentingDeleteDataAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash.fill")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                redirectToNewDrillConfigurationIfNeeded()
            }) {
                Text("Add New")
                    .fontWeight(.medium)
                    .frame(
                        width: Constants.newSessionButton.width,
                        height: Constants.newSessionButton.height
                    )
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Circle())
            .background(
                Circle()
                    .shadow(radius: 8, y: 2)
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func clearData() {
        let allDrills = drillContainers.map(\.drills).flatMap {
            $0
        }
        removeAudioRecordings(for: allDrills)
        withAnimation {
            modelContext.container.deleteAllData()
        }
    }
    
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
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            let sem = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { success in
                hasMicrophoneAccess = success
                sem.signal()
            })
            _ = sem.wait(timeout: DispatchTime.distantFuture)
        case .denied, .restricted:
            hasMicrophoneAccess = false
        case .authorized:
            hasMicrophoneAccess = true
        @unknown default:
            assertionFailure("unknown authorization status for microphone access: \(AVCaptureDevice.authorizationStatus(for: .audio))")
            hasMicrophoneAccess = false
        }
        
        if !hasMicrophoneAccess {
            throw AppError.Microphone.noAccess
        }
    }
    
    private func removeAudioRecordings(for drills: [Drill]) {
        drills.forEach { drill in
            if let recordingURL = drill.recordingURL {
                do {
                    try FileManager.default.removeItem(at: recordingURL)
                } catch {
                    Logger.sessionsListView.error("Failed to remove audio recording at url: \(recordingURL) with error: \(error)")
                }
            }
        }
    }
}

// MARK: - Logger

private extension Logger {
    static let sessionsListView = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.SessionsListView",
        category: String(describing: SessionsListView.self)
    )
}

// MARK: - Previews

#Preview("With Data") {
    MainActor.assumeIsolated {
        SessionsListView(
            watchDataSynchronizer: WatchDataSynchronizer(
                modelContext: DrillSessionsContainerSampleData.container.mainContext
            )
        )
        .modelContainer(DrillSessionsContainerSampleData.container)
    }
}

#Preview("No container") {
    SessionsListView(
        watchDataSynchronizer: WatchDataSynchronizer(
            modelContext: DrillSessionsContainerSampleData.container.mainContext
        )
    )
}
