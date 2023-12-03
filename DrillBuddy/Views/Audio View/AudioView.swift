//
//  AudioView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-24.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - AudioView

struct AudioView: View {
    
    // MARK: - Private Properties
    
    private let timeMarks: [TimeInterval]
    
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer
    @State private var currentTime: TimeInterval = 0
    
    @State private var error: Error?
    
    @State private var timerCancellable: AnyCancellable?
    
    // MARK: - Init
    
    init?(audioURL: URL, timeMarks: [TimeInterval] = []) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(filePath: audioURL.relativePath))
            self.timeMarks = timeMarks
        } catch {
            LogManager.log(.fault, module: .audioView, message: "Failed to initialize player with url: \(audioURL), with error: \(error)")
            return nil
        }
    }
    
    init?(audioData: Data, timeMarks: [TimeInterval] = []) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            self.timeMarks = timeMarks
        } catch {
            LogManager.log(.fault, module: .audioView, message: "Failed to initialize player with data \(audioData), with error: \(error)")
            return nil
        }
    }
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Button(action: {
                isPlaying.toggle()
                isPlaying ? playAudio() : pauseAudio()
            }, label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            })
            .padding(.horizontal)

            VStack {
                HStack {
                    Text(
                        Duration.seconds(audioPlayer.currentTime)
                            .formatted(.time(pattern: .minuteSecond))
                    )
                    Spacer()
                    Text(
                        Duration.seconds(audioPlayer.duration)
                            .formatted(.time(pattern: .minuteSecond))
                    )
                }
                ZStack {
                    Slider(
                        value: Binding(
                            get: {
                                currentTime
                            }, set: { newValue in
                                audioPlayer.currentTime = newValue
                                currentTime = newValue
                            }
                        ),
                        in: 0...audioPlayer.duration
                    )
                    .background(
                        Group {
                            if timeMarks.isEmpty {
                                EmptyView()
                            } else {
                                GeometryReader { geometry in
                                    makeTimeMarks(for: timeMarks, size: geometry.size)
                                        .offset(x: 0)
                                        .foregroundStyle(Color.red)
                                        .frame(width: geometry.size.width)
                                }
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.gray.opacity(0.2))
        )
        .errorAlert(error: $error)
        .onAppear {
            do {
                try AudioSessionManager.startAudioSession(category: .playback)
            } catch {
                self.error = error
            }
        }
        .onDisappear {
            pauseAudio()
        }
    }
    
    private func makeTimeMarks(for timeMarks: [TimeInterval], size: CGSize) -> some View {
        let duration = audioPlayer.duration
        
        let marksData = timeMarks.enumerated()
            .map { index, mark -> (position: CGPoint, size: CGSize, color: Color) in
                (
                    position: CGPoint(x: CGFloat(mark / duration) * size.width, y: size.height / 2),
                    size: CGSize(width: 2, height: size.height),
                    color: (index + 1) % 2 == 0 ? Color.red : Color.blue
                )
            }
        
        return Group {
            ForEach(Array(marksData.enumerated()), id: \.offset) { index, data in
                Rectangle()
                    .position(data.position)
                    .frame(width: data.size.width, height: data.size.height)
                    .foregroundStyle(data.color)
            }
        }
        .frame(width: size.width, alignment: .leading)
    }
    
    // MARK: - Private Methods
    
    private func playAudio() {
        audioPlayer.play()
        startMonitoringTime()
    }
    
    private func pauseAudio() {
        audioPlayer.pause()
        stopMonitoringTime()
    }
    
    private func startMonitoringTime(interval: TimeInterval = 0.5) {
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                isPlaying = audioPlayer.isPlaying
                currentTime = audioPlayer.currentTime
            }
    }
    
    private func stopMonitoringTime() {
        timerCancellable?.cancel()
    }
}

// MARK: - Preview

#Preview {
    AudioView(
        audioURL: DrillSessionsContainerSampleData.testAudioURL,
        timeMarks: [1, 1.5, 2, 3, 30, 60, 65, 66, 120, 240]
    )
}

//URL(string: "http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")!
