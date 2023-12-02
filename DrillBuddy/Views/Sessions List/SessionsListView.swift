//
//  SessionsListView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import AVFoundation
import SwiftUI
import SwiftData

struct SessionsListView: View {

    // MARK: - Constants
    
    private enum Constants {
        static let newSessionButton: CGSize = CGSize(
            width: 70,
            height: 70
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
        Group {
            if drillContainers.isEmpty {
                emptyView
            } else {
                listView
                    .navigationTitle("My Sessions")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
        .navigationTitle("Drills")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarHidden(false)
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
                    .padding(.vertical, 8)
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
                                
                                if drill.notes.isEmpty == false {
                                    Image(systemName: "pencil")//"square.and.pencil")
                                        .imageScale(.medium)
                                        .foregroundStyle(Color.blue)
                                }
                                
                                if drill.recordingURL != nil {
                                    Image(systemName: "speaker.3.fill")
                                        .imageScale(.medium)
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
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: {
                    redirectToNewDrillConfigurationIfNeeded()
                }) {
                    Text("Add\nNew")
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
                .padding(.bottom, 8)
                .padding(.trailing)
            }
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
                    LogManager.log(.error, module: .sessionsListView, message: "Failed to remove audio recording at url: \(recordingURL) with error: \(error)")
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("With Data") {
    MainActor.assumeIsolated {
        NavigationStack {
            SessionsListView(
                watchDataSynchronizer: WatchDataSynchronizer(
                    modelContext: DrillSessionsContainerSampleData.container.mainContext
                )
            )
            .modelContainer(DrillSessionsContainerSampleData.container)
        }
    }
}

#Preview("No container") {
    NavigationStack {
        SessionsListView(
            watchDataSynchronizer: WatchDataSynchronizer(
                modelContext: DrillSessionsContainerSampleData.container.mainContext
            )
        )
    }
}
