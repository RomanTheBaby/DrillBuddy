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
    
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer
    @State private var currentTime: TimeInterval = 0
    
    @State private var error: Error?
    
    @State private var timerCancellable: AnyCancellable?
    
    // MARK: - Init
    
    init?(audioURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(filePath: audioURL.relativePath))
        } catch {
            LogManager.log(.fault, module: .audioView, message: "Failed to initialize player with url: \(audioURL), with error: \(error)")
            return nil
        }
    }
    
    init?(audioData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
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
        audioURL: DrillSessionsContainerSampleData.testAudioURL
    )
}

//URL(string: "http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")!
