//
//  DrillRecordingView.swift
//  DrillBuddy Watch App
//
//  Created by Roman on 2023-10-16.
//

import Charts
import SwiftData
import SwiftUI

struct DrillRecordingView: View {
    
    // MARK: - Tab
    
    private enum Tab {
        case information
        case controls
        
        var title: String {
            switch self {
            case .information:
                return "Information"
            case .controls:
                return "Controls"
            }
        }
    }
    
    // MARK: - Properties
    
    @StateObject var viewModel: DrillRecordingViewModel
    
    @State private var selectedTab: Tab = .information
    @Environment(\.dismiss) private var dismiss

    // MARK: - View
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .standBy:
                ZStack {
                    Color.red
                        .ignoresSafeArea()
                    
                    Text("STAND BY")
                        .font(.system(.largeTitle, weight: .bold))
                        .foregroundStyle(.white)
                }
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    if isInPreview == false {
                        viewModel.startRecordingAfterRandomDelay()
                    }
                }
            case .recording:
                TabView(selection: $selectedTab) {
                    statisticsView
                        .navigationTitle("Recording Drill")
                        .tabItem { Text(Tab.information.title) }
                        .tag(Tab.information)
                    
                    VStack {
                        Button {
                            viewModel.stopRecording()
                            
                            if viewModel.drillEntries.isEmpty {
                                dismiss()
                            }
                        } label: {
                            Text("FINISH")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(alignment: .center)
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .shadow(radius: 5)
                    }
                    .navigationTitle(Tab.controls.title)
                    .tabItem { Text(Tab.controls.title) }
                    .tag(Tab.controls)
                }
                .blur(radius: viewModel.isPersistingData ? 10 : 0)
                .overlay(loadingOverlay)
                
            case .summary:
                TabView(selection: $selectedTab) {
                    statisticsView
                        .navigationTitle("Summary")
                        .tabItem { Text(Tab.information.title) }
                        .tag(Tab.information)
                    
                    summaryView
                        .tabItem { Text(Tab.controls.title) }
                        .tag(Tab.controls)
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Private Views
    
    private var statisticsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.recodingStatistics.shotsCount, format: .number)
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundStyle(Color.orange)
                Text("# of Shots")
            }
            
            HStack {
                Text(viewModel.recodingStatistics.firstShotDelay.minuteSecondMS)
                    .font(.system(.title2, weight: .medium))
                    .foregroundStyle(Color.teal)
                
                Text("1st shot\ndelay")
                    .font(.system(size: 10))
            }
            
            HStack {
                Text(viewModel.recodingStatistics.shotsSplit.minuteSecondMS)
                    .font(.system(.title2, weight: .medium))
                    .foregroundStyle(Color.yellow)
                Text("avg.\nsplit")
                    .font(.system(size: 10))
            }
            
            HStack {
                Text(
                    Duration.seconds(viewModel.recodingStatistics.totalTime)
                        .formatted(.time(pattern: .minuteSecond))
                )
                .font(.system(.title, weight: .bold))
                .foregroundStyle(Color.green)
                
                Text("Duration")
            }
        }
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading) {
            Chart {
                ForEach(Array(viewModel.drillEntries.enumerated()), id: \.offset) { index, entry in
                    BarMark(
                        x: .value("Shot #", "#\(index)"),
                        y: .value("Time", entry.time)
                    )
                }
                RuleMark(
                    y: .value("Threshold", viewModel.recodingStatistics.shotsSplit)
                )
                .foregroundStyle(.red)
                .foregroundStyle(by: .value("Average", "Avg. Split"))
            }
            .chartLegend(.visible)
            .chartForegroundStyleScale(["Avg. Split": Color.red, "Time": Color.blue])
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(.callout, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if viewModel.isPersistingData {
            ProgressView()
                .controlSize(.regular)
                .progressViewStyle(.circular)
        }
    }
}

// MARK: - Time Interval Extension

extension TimeInterval {
    var minuteSecondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
}

// MARK: - Previews

#Preview("Stand By") {
    NavigationStack {
        DrillRecordingView(
            viewModel: DrillRecordingViewModel(
                initialState: .standBy,
                modelContext: DrillSessionsContainerSampleData.container.mainContext,
                configuration: .default
            )
        )
    }
}

#Preview("Recording") {
    NavigationStack {
        DrillRecordingView(
            viewModel: DrillRecordingViewModel(
                initialState: .recording,
                modelContext: DrillSessionsContainerSampleData.container.mainContext,
                configuration: .default
            )
        )
    }
}

#Preview("Summary") {
    NavigationStack {
        DrillRecordingView(
            viewModel: DrillRecordingViewModel(
                initialState: .summary,
                modelContext: DrillSessionsContainerSampleData.container.mainContext,
                configuration: .default
            )
        )
    }
}
