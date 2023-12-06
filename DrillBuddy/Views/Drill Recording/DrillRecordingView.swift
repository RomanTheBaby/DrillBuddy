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
    
    @State private var showLoadingOverlay: Bool = false
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
                VStack(alignment: .leading) {
                    Text("Recording Drill...")
                    
                    statisticsView
                    
                    GeometryReader(content: { geometry in
                        DetectSoundsView(
                            confidence: viewModel.lastDetectedSoundConfidenceLevel,
                            label: String(format: "%.2f%%%", viewModel.lastDetectedSoundConfidenceLevel * 100),
                            numberOfBars: 20,
                            labelForBar: { barIndex in
                                switch barIndex {
                                case 0:
                                    Text("100%")
                                        .font(.caption2)
                                case 5:
                                    Text("75%")
                                        .font(.caption2)
                                case 10:
                                    Text("50%")
                                        .font(.caption2)
                                case 15:
                                    Text("25%")
                                        .font(.caption2)
                                case 19:
                                    Text("5%")
                                        .font(.caption2)
                                default:
                                    EmptyView()
                                }
                            }
                        )
                        .frame(
                            width: geometry.size.width / 2,
                            height: geometry.size.height,
                            alignment: .center
                        )
                        .offset(x: geometry.frame(in: .local).midX - (geometry.size.width / 4))
                    })
                    
                    if viewModel.tournament == nil {
                        Button {
                            showLoadingOverlay = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                viewModel.stopRecording()
                                
                                if viewModel.drillEntries.isEmpty {
                                    customFinishAction?() ?? dismiss()
                                }
                                
                                showLoadingOverlay = false
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
            case .summary:
                summaryView
            }
        }
        .navigationBarBackButtonHidden(true)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay(isLoading: showLoadingOverlay)
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
    
    @ViewBuilder
    private var summaryView: some View {
        if let drill = viewModel.drill {
            VStack {
                DrillDetailView(drill: drill, showDeleteToolbarButton: false)
                summaryFooter
            }
        } else {
            minimalSummaryView
                .navigationTitle("Summary")
        }
    }
    
    private var minimalSummaryView: some View {
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
            
            summaryFooter
        }
    }
    
    @ViewBuilder
    private var summaryFooter: some View {
        if let tournament = viewModel.tournament,
            viewModel.drillEntries.isEmpty == false,
            let user = viewModel.currentUser {
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
            HStack(spacing: 8) {
                if viewModel.drill != nil {
                    Button {
                        do {
                            try viewModel.deleteRecordedDrill()
                            customFinishAction?() ?? dismiss()
                        } catch {
                            LogManager.log(.error, module: .drillRecording, message: "Failed to delete drill with error: \(error)")
                        }
                    } label: {
                        Text("Delete")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.red)
                    .shadow(radius: 5)
                }
                
                Button {
                    customFinishAction?() ?? dismiss()
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .buttonStyle(.borderedProminent)
                .shadow(radius: 5)
            }
            .padding(.horizontal)
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
