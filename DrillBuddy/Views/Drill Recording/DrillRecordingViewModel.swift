//
//  DrillRecordingViewModel.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-30.
//

import Combine
import OSLog
import UIKit

class DrillRecordingViewModel: ObservableObject {
    
    // MARK: - RecodingStatistics
    
    struct RecodingStatistics {
        var shotsCount: Int = 0
        var shotsSplit: TimeInterval = 0
        var firstShotDelay: TimeInterval = 0
        var totalTime: TimeInterval = 0
        
        fileprivate mutating func setShotsCount(_ shotsCount: Int) {
            self.shotsCount = shotsCount
        }
        
        fileprivate mutating func setShotsSplit(_ shotsSplit: TimeInterval) {
            self.shotsSplit = shotsSplit
        }
        
        fileprivate mutating func setFirstShotDelay(_ firstShotDelay: TimeInterval) {
            self.firstShotDelay = firstShotDelay
        }
        
        fileprivate mutating func setTotalTime(_ totalTime: TimeInterval) {
            self.totalTime = totalTime
        }
    }
    
    struct DrillEntry {
        var confidence: Double
        var time: TimeInterval
    }
    
    // MARK: - Status
    
    enum State: Equatable {
        case standBy
        case recording
        case summary
    }
    
    // MARK: - Public Properties
    
    @Published var state: State
    @Published var lastDetectedSoundConfidenceLevel: Double = 0
    @Published private(set) var recodingStatistics: RecodingStatistics = .init()
    private(set) var drillEntries: [DrillEntry] = []
    
    // MARK: - Private Properties
    
    private let configuration: DrillRecordingConfiguration
    private let audioRecorder: AudioRecorder
    private let soundIdentifier: SoundIdentifier
    
    
    private var soundIdentifyingCancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    
    private lazy var startDate = Date()
    
    // MARK: - Init
    
    init(
        initialState: State = .standBy, 
        configuration: DrillRecordingConfiguration,
        audioRecorder: AudioRecorder = .init(),
        soundIdentifier: SoundIdentifier = .init()
    ) {
        self.state = initialState
        self.configuration = configuration
        self.audioRecorder = audioRecorder
        self.soundIdentifier = soundIdentifier
    }
    
    deinit {
        timerCancellable?.cancel()
        soundIdentifyingCancellable?.cancel()
    }
    
    // MARK: - Public Methods
    
    func startRecordingAfterRandomDelay() {
        state = .standBy
        let randomDelay = TimeInterval.random(in: 1...configuration.maxSessionDelay)
        timerCancellable = Timer.publish(every: randomDelay, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerCancellable?.cancel()
                
                self?.startRecording()
            }
    }
    
    func startRecording() {
        state = .recording
        startDate = Date()
        do {
            let soundIdentifyingSubject = try soundIdentifier.startDetectingSounds(
                soundTypes: [.gunshot, .clapping, .fingerSnapping],
                minRequiredConfidence: configuration.minimumSoundConfidenceLevel,
                inferenceWindowSize: configuration.inferenceWindowSize,
                overlapFactor: configuration.overlapFactor
            )
            soundIdentifyingCancellable = soundIdentifyingSubject.sink { [weak self] _ in
                self?.soundIdentifyingCancellable?.cancel()
            } receiveValue: { [weak self] detectedSoundInfo in
                guard let self else {
                    return
                }
                Logger.drillRecording.debug("Detected sound of type: \(detectedSoundInfo.soundType.identifier), confidence: \(detectedSoundInfo.confidence)")
                self.handleDetectedSound(detectedSoundInfo)
            }

            startRecordingAudioIfNeeded()
        } catch {
            Logger.drillRecording.error("Failed to start identifying sounds with error: \(error)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        state = .summary

        soundIdentifyingCancellable?.cancel()
        timerCancellable?.cancel()
        
        audioRecorder.stopRecording()
        soundIdentifier.stopDetectingSounds()
    }
    
    // MARK: - Private Methods
    
    private func startRecordingAudioIfNeeded() {
        guard configuration.shouldRecordAudio else {
            return
        }
    }
    
    private func handleDetectedSound(_ detectedSoundInfo: SoundIdentifier.DetectedSoundInfo, detectedDate: Date = Date()) {
        /// Time since start of the drill
        let time = detectedDate.timeIntervalSince(startDate)
        let latestEntry = DrillEntry(confidence: detectedSoundInfo.confidence, time: time)
        drillEntries.append(latestEntry)
        
        recodingStatistics.setShotsCount(drillEntries.count)
        
        if drillEntries.count == 1 {
            recodingStatistics.setFirstShotDelay(latestEntry.time)
            recodingStatistics.setShotsSplit(latestEntry.time)
        } else {
            let shotTimes = drillEntries.map(\.time)
            let splits = shotTimes.dropLast(1).enumerated().map { index, time -> Double in
                shotTimes[index + 1] - time
            }
                
            recodingStatistics.setShotsSplit(splits.reduce(0, +) / Double(splits.count))
        }

        recodingStatistics.setTotalTime(latestEntry.time)
        
        // Updating & reseting last confidence level property
        lastDetectedSoundConfidenceLevel = latestEntry.confidence
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                self?.timerCancellable?.cancel()
                self?.lastDetectedSoundConfidenceLevel = 0
            })
    }
}


// MARK: - Logger

private extension Logger {
    static let drillRecording = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.DrillRecordingViewModel",
        category: String(describing: DrillRecordingViewModel.self)
    )
}
