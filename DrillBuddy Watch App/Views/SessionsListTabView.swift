//
//  DrillListTabView.swift
//  DrillBuddy Watch App
//
//  Created by Roman on 2023-09-23.
//

import AVFoundation
import SwiftUI

struct SessionsListTabView: View {
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

    // MARK: - Properties
    
    @State private var error: Error?
    @State private var redirectToNewDrillConfigurationView = false
    
    @State var drillContainers: [DrillsSessionsContainer] = []
    @State var selectedTab: Tab = .controls
    var customNewSessionAction: (() -> Void)? = nil
    
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
            Text("Yolo")
        }
        .onChange(of: drillContainers) { _, newValue in
            if newValue.isEmpty {
                selectedTab = .controls
            }
        }
    }
    
    private var sessionsListView: some View {
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
////                    redirectToNewDrillConfigurationIfNeeded()
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
            Text("You do not have any drills yet...")
                .multilineTextAlignment(.center)
                .font(.system(.title3, weight: .medium))
            
            Spacer()
            
            Button(action: {
                redirectToNewDrillConfigurationIfNeeded()
            }) {
                Label("Add New", systemImage: "plus")
//                    .fontWeight(.medium)
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
                        
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(Color.red)
                    Text("Clear Data")
                }
                .disabled(drillContainers.isEmpty)
                
                VStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .tint(Color.yellow)
                    Text("Sync Data")
                }
                .disabled(drillContainers.isEmpty)
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
        if isInPreview {
            throw AppError.Microphone.noAccessPreview
        }
        
        var hasMicrophoneAccess = false
        
        let sem = DispatchSemaphore(value: 0)
        AVAudioApplication.requestRecordPermission { hasPermission in
            hasMicrophoneAccess = hasPermission
            sem.signal()
        }
        
        if !hasMicrophoneAccess {
            throw AppError.Microphone.noAccess
        }
    }
}

// MARK: - Previews

#Preview("With Data") {
    MainActor.assumeIsolated {
        NavigationStack {
            SessionsListTabView(
                drillContainers: DrillSessionsContainerSampleData.previewModels,
                selectedTab: .recordslist
            )
        }
    }
}

#Preview("No Data") {
    NavigationStack {
        SessionsListTabView(drillContainers: [])
    }
}
