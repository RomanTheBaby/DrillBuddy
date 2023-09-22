//
//  SessionsListView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

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
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DrillsSessionsContainer.date, order: .reverse, animation: .smooth)
    private var drillContainers: [DrillsSessionsContainer]
    
    // MARK: - View
    
    var body: some View {
        #if os(iOS)
        phoneView
        #elseif os(macOS)
        macView
        #elseif os(watchOS)
        watchView
        #endif
    }
    
    var phoneView: some View {
        NavigationView {
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
                    Button(action: clearData) {
                        Label("Add Item", systemImage: "trash.fill")
                    }
                }
            }
        }
    }
    
    var macView: some View {
        NavigationStack {
            List {
                
            }
            .toolbar {
                ToolbarItem {
                    Button(action: clearData) {
                        Label("Add Item", systemImage: "trash.fill")
                    }
                }
            }
        }
    }
    
    var watchView: some View {
        NavigationStack {
        }
    }
    
    // MARK: - Private Methods
    
    private func clearData() {
        withAnimation {
            modelContext.container.deleteAllData()
        }
    }
}

#Preview {
    MainActor.assumeIsolated {
        SessionsListView()
            .modelContainer(DrillSessionsContainerSampleData.container)
    }
}
