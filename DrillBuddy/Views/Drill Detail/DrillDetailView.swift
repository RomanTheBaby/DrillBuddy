//
//  DrillDetailView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-17.
//

import Charts
import SwiftData
import SwiftUI

// MARK: - DrillDetailView

struct DrillDetailView: View {
    
    // MARK: Tab
    
    private enum Tab {
        case notes
        case splitsChart
        case recordingConfiguration
    }
    
    // MARK: Properties
    
    var drill: Drill
    
    private var averageSplit: TimeInterval {
        drill.sounds.averageSplit
    }
    
    private let showDeleteToolbarButton: Bool
    
    @State private var error: Error?
    @State private var isPresentingDeleteDataAlert = false
    @State private var showLoadingOverlay: Bool = false
    @State private var showConfigurationOverlay: Bool = false
    @State private var notes: String = ""
    @State private var selectedTab: Tab = .splitsChart
    
    @FocusState private var isFirstResponder: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    init(drill: Drill, showDeleteToolbarButton: Bool = true) {
        self.drill = drill
        self.showDeleteToolbarButton = showDeleteToolbarButton
        self._notes = State(initialValue: drill.notes)
    }
    
    // MARK: View
    
    var body: some View {
        VStack(spacing: 8) {
            VStack {
                Text("Session for:")
                    .font(.system(.title, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(drill.date.formatted(.dateTime.day().weekday().month().year().hour().minute()))
                    .font(.system(.subheadline, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Group {
                    Spacer()
                        .frame(height: 8)
                    
                    HStack {
                        Text(drill.sounds.count, format: .number)
                            .font(.system(.title, weight: .bold))
                        Text("# of Shots")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let firstSound = drill.sounds.first {
                        HStack {
                            Text(firstSound.time.minuteSecondMS)
                                .font(.system(.title, weight: .bold))
                            
                            Text("1st shot delay")
                        }
                    }
                    
                    HStack {
                        Text(averageSplit.minuteSecondMS)
                            .font(.system(.title, weight: .bold))
                        Text("avg. split")
                    }
                    
                    if let lastSound = drill.sounds.last {
                        HStack {
                            Text(
                                Duration.seconds(lastSound.time)
                                    .formatted(.time(pattern: .minuteSecond))
                            )
                            .font(.system(.title, weight: .bold))
                            
                            Text("Duration")
                        }
                    }
                    
                    Spacer()
                        .frame(height: 8)
                }
                .padding(.horizontal)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
            .padding(.horizontal)
            
            #if DEBUG
            if let recordingURL = isInPreview ? DrillSessionsContainerSampleData.testAudioURL : drill.recordingURL,
               let audioView = AudioView(audioURL: recordingURL, timeMarks: drill.sounds.map(\.time)) {
                audioView
                    .padding(.horizontal)
            }
            #else
            if let recordingURL = drill.recordingURL,
               let audioView = AudioView(audioURL: recordingURL, timeMarks: drill.sounds.map(\.time)) {
                audioView
                    .padding(.horizontal)
            }
            #endif
            
            
            TabView(selection: $selectedTab) {
                VStack(spacing: 8) {
                    Text("Notes")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.title, weight: .bold))
                        .padding(.horizontal)
                    
                    TextField("Add Your Notes...", text: $notes, axis: .vertical)
                        .lineLimit(5...)
                        .focused($isFirstResponder)
                        .autocorrectionDisabled(true)
                        .submitLabel(.return)
                        .onSubmit {
                            isFirstResponder = false
                            drill.updateNotes(newNotes: notes)
                            try? modelContext.save()
                        }
                        .onDisappear {
                            isFirstResponder = false
                            drill.updateNotes(newNotes: notes)
                            try? modelContext.save()
                        }
                        .textFieldStyle(.roundedBorder)//.plain)
                        .padding([.bottom, .horizontal])
                        
                    Spacer()
                }
                .tag(Tab.notes)
                
                DrillSplitsChartView(drill: drill)
                    .padding(.bottom)
                    .tag(Tab.splitsChart)
                
                DrillRecordingParametersView(drill: drill)
                    .tag(Tab.recordingConfiguration)
            }
            .onChange(of: selectedTab, {
                isFirstResponder = false
                drill.updateNotes(newNotes: notes)
                try? modelContext.save()
            })
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .popover(isPresented: $showConfigurationOverlay, content: {
            NavigationStack {
                DrillRecordingParametersView(drill: drill)
            }
        })
        .errorAlert(error: $error)
        .loadingOverlay(isLoading: showLoadingOverlay)
        .confirmationDialog(
            "Confirm Action",
            isPresented: $isPresentingDeleteDataAlert
        ) {
            Button("Delete", role: .destructive, action: deleteDrill)
        } message: {
            Text("Are you sure you want to this data for this drill?\nThis action cannot be undone")
        }
        .toolbar {
            if showDeleteToolbarButton {
                ToolbarItem {
                    Button {
                        isPresentingDeleteDataAlert = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash.fill")
                    }
                }
            }
            
            ToolbarItem {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Private Methods
    
    private func deleteDrill() {
        showLoadingOverlay = true
        
        do {
            try deleteRecording(for: drill)
            withAnimation {
                modelContext.delete(drill)
                showLoadingOverlay = false
                dismiss()
            }
        } catch {
            showLoadingOverlay = false
            self.error = error
        }
    }
    
    private func deleteRecording(for drill: Drill) throws {
        guard let recordingURL = drill.recordingURL else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: recordingURL)
        } catch {
            LogManager.log(.error, module: .sessionsListView, message: "Failed to remove audio recording at url: \(recordingURL) with error: \(error)")
            throw error
        }
    }
}

// MARK: - Drill

struct DrillSplitsChartView: View {
    var drill: Drill
    
    var body: some View {
        Chart {
            ForEach(Array(drill.sounds.enumerated()), id: \.offset) { index, entry in
                BarMark(
                    x: .value("Shot #", "#\(index)"),
                    y: .value("Time", entry.time)
                )
            }
            RuleMark(
                y: .value("Threshold", drill.sounds.averageSplit)
            )
            .foregroundStyle(.red)
            .foregroundStyle(by: .value("Average", "Avg. Split"))
        }
        .chartLegend(.visible)
        .chartForegroundStyleScale(["Avg. Split": Color.red, "Time": Color.blue])
        .padding(.horizontal)
    }
}

// MARK: - DrillRecordingParametersView

private struct DrillRecordingParametersView: View {
    
    var drill: Drill
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                    .frame(height: 8)
                
                HStack {
                    Text("Min Confidence Level")
                        .font(.system(.title3, weight: .bold))
                    Text(String(format: "%.2f", drill.recordingConfiguration.minimumSoundConfidenceLevel))
                    Spacer()
                }
                
                HStack {
                    Text("Min Confidence Level")
                        .font(.system(.title3, weight: .bold))
                    Text(String(format: "%.2f", drill.recordingConfiguration.inferenceWindowSize))
                    Spacer()
                }
                
                HStack {
                    Text("Overlap Factor")
                        .font(.system(.title3, weight: .bold))
                    Text(String(format: "%.2f", drill.recordingConfiguration.overlapFactor))
                    Spacer()
                }
                
                HStack {
                    Text("Max Shots")
                        .font(.system(.title3, weight: .bold))
                    Text("\(drill.recordingConfiguration.maxShots)")
                    Spacer()
                }
                
                HStack {
                    Text("Max Delay")
                        .font(.system(.title3, weight: .bold))
                    Text("\(drill.recordingConfiguration.maxSessionDelay)")
                    Spacer()
                }
                
                HStack {
                    Text("With Audio")
                        .font(.system(.title3, weight: .bold))
                    Text("\(drill.recordingConfiguration.shouldRecordAudio ? "YES" : "NO")")
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 8)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.2))
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// MARK: - Time Interval Extension

private extension TimeInterval {
    var minuteSecondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
}

#if DEBUG

// MARK: - Previews

#Preview {
    NavigationStack {
        DrillDetailView(
            drill: DrillSessionsContainerSampleData.previewDrillsContainers[0].drills[0]
        )
    }
}

#endif
