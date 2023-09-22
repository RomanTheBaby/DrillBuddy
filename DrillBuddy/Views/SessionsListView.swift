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
            width: 100,
            height: 100
        )
    }
    
    // MARK: - Properties
    
    @State private var isPresentingDeleteDataAlert: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DrillsSessionsContainer.date, order: .reverse, animation: .smooth)
    private var drillContainers: [DrillsSessionsContainer]
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            if drillContainers.isEmpty {
                VStack {
                    Text("You do not have any drill yet...")
                        .font(.system(.title2, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: EmptyView()) {
                        Label("Add New", systemImage: "plus")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.blue)
                    .padding(.horizontal)
                }
            } else {
                listView
                    .confirmationDialog(
                        "Confirm Action",
                        isPresented: $isPresentingDeleteDataAlert
                    ) {
                        Button("Delete All", role: .destructive, action: clearData)
                    } message: {
                        Text("Are you sure you want to delete all records?\nThis action cannot be undone")
                    }
                    .navigationTitle("My Sessions")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
        .onAppear {
            if isInPreview == false {
                ensureMicrophoneAccess()
            }
        }
    }
    
    private var listView: some View {
        #if os(iOS)
            phoneView
        #elseif os(macOS)
            macView
        #elseif os(watchOS)
            watchView
        #endif
    }
    
    private var phoneView: some View {
        List {
            ForEach(drillContainers) { container in
                Section {
                    ForEach(Array(container.drills.enumerated()), id: \.offset) { index, drill in
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
            //                ToolbarItem(placement: .navigationBarTrailing) {
            //                    EditButton()
            //                }
            ToolbarItem {
                Button {
                    isPresentingDeleteDataAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash.fill")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            buttonView
        }
    }
    
    private var macView: some View {
        List {
            
        }
        .toolbar {
            ToolbarItem {
                Button(action: clearData) {
                    Label("Delete all", systemImage: "trash.fill")
                }
            }
        }
    }
    
    private var watchView: some View {
        EmptyView()
    }
    
    private var buttonView: some View {
//        NavigationLink(destination: DrillConfigurationView()) {
        NavigationLink(destination: EmptyView()) {
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
    
    // MARK: - Private Methods
    
    private func clearData() {
        withAnimation {
            modelContext.container.deleteAllData()
        }
    }
    
    private func ensureMicrophoneAccess() {
        var hasMicrophoneAccess = false
        
        #if os(watchOS)
        let sem = DispatchSemaphore(value: 0)
        
        AVAudioApplication.requestRecordPermission { hasPermission in
            hasMicrophoneAccess = hasPermission
            sem.signal()
        }
        #else
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
            break
        case .authorized:
            hasMicrophoneAccess = true
        @unknown default:
            assertionFailure("unknown authorization status for microphone access: \(AVCaptureDevice.authorizationStatus(for: .audio))")
            hasMicrophoneAccess = false
        }
        #endif

        if !hasMicrophoneAccess {
//            throw SystemAudioClassificationError.noMicrophoneAccess
        }
    }
}

// MARK: - Previews

#Preview("With Data") {
    MainActor.assumeIsolated {
        SessionsListView()
            .modelContainer(DrillSessionsContainerSampleData.container)
    }
}

#Preview("No container") {
    SessionsListView()
}
