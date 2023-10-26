//
//  DrillRecordingViewModel.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-30.
//

import Combine
import OSLog
import SwiftData

class DrillRecordingViewModel: ObservableObject {
    
    // MARK: - RecordingStatistics
    
    struct RecordingStatistics {
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
    
    // MARK: - Status
    
    enum State: Equatable {
        case standBy
        case recording
        case summary
    }
    
    // MARK: - Public Properties
    
    @Published private(set) var state: State
    @Published private(set) var lastDetectedSoundConfidenceLevel: Double = 0
    @Published private(set) var recordingStatistics: RecordingStatistics = .init()
    @Published private(set) var isPersistingData = false
    private(set) var drillEntries: [DrillEntry] = []
    
    // MARK: - Private Properties
    
    private let configuration: DrillRecordingConfiguration
    private let audioRecorder: AudioRecorder
    private let soundIdentifier: SoundIdentifier
    private let modelContext: ModelContext
    
    private var audioRecordingURL: URL?
    
    private var soundIdentifyingCancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    
    private lazy var startDate = Date()
    
    // MARK: - Init
    
    init(
        initialState: State = .standBy, 
        modelContext: ModelContext,
        configuration: DrillRecordingConfiguration,
        audioRecorder: AudioRecorder = .init(),
        soundIdentifier: SoundIdentifier = .init()
    ) {
        self.state = initialState
        self.modelContext = modelContext
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

            do {
                try startRecordingAudioIfNeeded()
            } catch {
                Logger.drillRecording.error("Failed to start recording audio with error: \(error)")
                stopRecording()
            }
        } catch {
            Logger.drillRecording.error("Failed to start identifying sounds with error: \(error)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        isPersistingData = true
        
        soundIdentifyingCancellable?.cancel()
        timerCancellable?.cancel()
        
        audioRecorder.stopRecording()
        soundIdentifier.stopDetectingSounds()
        
        saveDrillsSessionsContainer(
            in: modelContext,
            startDate: startDate,
            drillEntries: drillEntries
        )

        isPersistingData = false
        state = .summary
    }
    
    // MARK: - Private Methods
    
    private func startRecordingAudioIfNeeded() throws {
        guard configuration.shouldRecordAudio else {
            return
        }
        
        audioRecordingURL = try audioRecorder.startRecording(
            folderName: DateFormatter.audioFolderName.string(from: startDate),
            fileName: DateFormatter.audioFileName.string(from: startDate)
        )
    }
    
    private func handleDetectedSound(_ detectedSoundInfo: SoundIdentifier.DetectedSoundInfo, detectedDate: Date = Date()) {
        /// Time since start of the drill
        let time = detectedDate.timeIntervalSince(startDate)
        let latestEntry = DrillEntry(time: time, confidence: detectedSoundInfo.confidence)
        drillEntries.append(latestEntry)
        
        recordingStatistics.setShotsCount(drillEntries.count)
        
        if drillEntries.count == 1 {
            recordingStatistics.setFirstShotDelay(latestEntry.time)
            recordingStatistics.setShotsSplit(latestEntry.time)
        } else {
            recordingStatistics.setShotsSplit(drillEntries.averageSplit)
        }

        recordingStatistics.setTotalTime(latestEntry.time)
        
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
    
    private func saveDrillsSessionsContainer(
        in modelContext: ModelContext,
        startDate: Date,
        drillEntries: [DrillEntry]
    ) {
        guard drillEntries.isEmpty == false else {
            return
        }
        
        let containerFormattedDate = DrillsSessionsContainer.formatDate(startDate)
        
        let predicate = #Predicate<DrillsSessionsContainer> { $0.date == containerFormattedDate }
        let descriptor = FetchDescriptor<DrillsSessionsContainer>(predicate: predicate)
        
        do {
            let containers = try modelContext.fetch(descriptor)
            
            let container = containers.first ?? DrillsSessionsContainer(context: modelContext, date: containerFormattedDate)
            if containers.isEmpty {
                modelContext.insert(container)
            }
            
            let drill = Drill(date: startDate, sounds: drillEntries, recordingURL: audioRecordingURL)
            container.addDrills([drill])
            
        } catch {
            Logger.drillRecording.error("Failed to fetch container for date: \(containerFormattedDate) with error: \(error)")
        }
    }
}

// MARK: - DateFormatter Helpers

private extension DateFormatter {
    static let audioFolderName: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter
    }()
    
    static let audioFileName: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm-a"
        return dateFormatter
    }()
}


// MARK: - Logger

private extension Logger {
    static let drillRecording = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.DrillRecordingViewModel",
        category: String(describing: DrillRecordingViewModel.self)
    )
}
