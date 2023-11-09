//
//  DrillRecordingView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import Charts
import SwiftData
import SwiftUI

struct DrillRecordingView: View {
    
    // MARK: - Properties
    
    var customFinishAction: (() -> Void)? = nil
    @StateObject var viewModel: DrillRecordingViewModel
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userStorage: UserStorage
    
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
                VStack(alignment: .leading) {
                    Text("Recording Drill...")
                    
                    statisticsView
                    
                    GeometryReader(content: { geometry in
                        DetectSoundsView(confidence: viewModel.lastDetectedSoundConfidenceLevel)
                            .frame(
                                width: geometry.size.width / 2,
                                height: geometry.size.height,
                                alignment: .center
                            )
                            .offset(x: geometry.frame(in: .local).midX - (geometry.size.width / 4))
                    })
                    
                    if viewModel.tournament == nil {
                        Button {
                            viewModel.stopRecording()
                            
                            if viewModel.drillEntries.isEmpty {
                                customFinishAction?() ?? dismiss()
                            }
                        } label: {
                            Text("FINISH")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(alignment: .center)
                        .buttonStyle(.borderedProminent)
                        .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
                .blur(radius: viewModel.isPersistingData ? 10 : 0)
                .overlay(loadingOverlay)
            case .summary:
                summaryView
                    .navigationTitle("Summary")
            }
        }
        .navigationBarBackButtonHidden(true)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay(isLoading: viewModel.showLoadingOverlay)
    }
    
    // MARK: - Private Views
    
    private var statisticsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.recordingStatistics.shotsCount, format: .number)
                    .font(.system(.largeTitle, weight: .bold))
                Text("# of Shots")
            }
            
            HStack {
                Text(viewModel.recordingStatistics.firstShotDelay.minuteSecondMS)
                    .font(.system(.largeTitle, weight: .bold))
                
                Text("1st shot delay")
            }
            
            HStack {
                Text(viewModel.recordingStatistics.shotsSplit.minuteSecondMS)
                    .font(.system(.largeTitle, weight: .bold))
                Text("avg. split")
            }
            
            HStack {
                Text(
                    Duration.seconds(viewModel.recordingStatistics.totalTime)
                        .formatted(.time(pattern: .minuteSecond))
                )
                .font(.system(.largeTitle, weight: .bold))
                
                Text("Duration")
            }
        }
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading) {
            statisticsView
                .padding(.horizontal)
            
            Spacer()
            
            Chart {
                ForEach(Array(viewModel.drillEntries.enumerated()), id: \.offset) { index, entry in
                    BarMark(
                        x: .value("Shot #", "#\(index)"),
                        y: .value("Time", entry.time)
                    )
                }
                RuleMark(
                    y: .value("Threshold", viewModel.recordingStatistics.shotsSplit)
                )
                .foregroundStyle(.red)
                .foregroundStyle(by: .value("Average", "Avg. Split"))
            }
            .chartLegend(.visible)
            .chartForegroundStyleScale(["Avg. Split": Color.red, "Time": Color.blue])
            .padding(.horizontal)
            
            if let tournament = viewModel.tournament, viewModel.drillEntries.isEmpty == false, let user = userStorage.currentUser {
                Button {
                    Task {
                        await viewModel.submit(for: tournament, user: user)
                        customFinishAction?() ?? dismiss()
                    }
                } label: {
                    Text("Submit Tournament Entry")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
                .shadow(radius: 5)
            } else {
                Button {
                    customFinishAction?() ?? dismiss()
                } label: {
                    Text("Done")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
                .shadow(radius: 5)
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

#Preview("Summary - Tournament") {
    NavigationStack {
        DrillRecordingView(
            viewModel: DrillRecordingViewModel(
                initialState: .summary,
                modelContext: DrillSessionsContainerSampleData.container.mainContext,
                tournament: TournamentPreviewData.mock,
                configuration: .default
            )
        )
    }
}

// MARK: - Time Interval Extension

private extension TimeInterval {
    var hourMinuteSecondMS: String {
        String(format:"%02d:%02d.%03d", minute, second, millisecond)
    }
    
    var minuteSecondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
}
