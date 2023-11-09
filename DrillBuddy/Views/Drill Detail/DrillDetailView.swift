//
//  DrillDetailView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-17.
//

import Charts
import SwiftUI

// MARK: - DrillDetailView

struct DrillDetailView: View {
    
    var drill: Drill
    
    private var averageSplit: TimeInterval {
        drill.sounds.averageSplit
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Session for:")
                    .font(.system(.title, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(drill.date.formatted(.dateTime.day().weekday().month().year().hour().minute()))
                    .font(.system(.subheadline, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 8)
            
            VStack(alignment: .leading) {
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
            }
            .padding(.horizontal)
            
            if let recordingURL = drill.recordingURL {
                AudioView(audioURL: recordingURL)
                    .padding(.horizontal)
            }
            
            Spacer()
                .frame(height: 16)
            
            VStack(alignment: .leading) {
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Time Interval Extension

private extension TimeInterval {
    var minuteSecondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
}

// MARK: - Previews

#Preview {
    DrillDetailView(
        drill: DrillSessionsContainerSampleData.previewDrillsContainers[0].drills[0]
    )
}
