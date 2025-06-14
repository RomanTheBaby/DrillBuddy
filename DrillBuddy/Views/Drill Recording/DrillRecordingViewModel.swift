//
//  DrillRecordingViewModel.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-30.
//

import Combine
import Foundation
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
    
    let tournament: Tournament?
    let currentUser: UserInfo?
    
    private(set) var drill: Drill?
    private(set) var drillEntries: [DrillEntry] = []
    
    @Published var error: Error?
    @Published private(set) var state: State
    @Published private(set) var lastDetectedSoundConfidenceLevel: Double = 0
    @Published private(set) var recordingStatistics: RecordingStatistics = RecordingStatistics()
    @Published private(set) var isPersistingData = false
    
    // MARK: - Private Properties
    
    private let configuration: DrillRecordingConfiguration
    private let audioRecorder: AudioRecorder
    private let soundIdentifier: SoundIdentifier
    
    #if !os(watchOS)
    private let firestoreService: FirestoreService = FirestoreService()
    #endif
    
    private let modelContext: ModelContext
    
    private var soundIdentifyingCancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    
    private lazy var startDate = Date()
    
    private var tournamentEntry: TournamentEntry?
    
    // MARK: - Init
    
    init(
        initialState: State = .standBy,
        modelContext: ModelContext,
        tournament: Tournament? = nil,
        currentUser: UserInfo? = nil,
        configuration: DrillRecordingConfiguration,
        audioRecorder: AudioRecorder = AudioRecorder(),
        soundIdentifier: SoundIdentifier = SoundIdentifier()
//        firestoreService: FirestoreService = FirestoreService()
    ) {
        self.state = initialState
        self.modelContext = modelContext
        self.tournament = tournament
        self.currentUser = currentUser
        self.configuration = configuration
        self.audioRecorder = audioRecorder
        self.soundIdentifier = soundIdentifier
//        self.firestoreService = firestoreService
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
        do {
            #if DEBUG
            let soundTypes: [SoundIdentifier.SoundType] = [.gunshot, .fingerSnapping]
            #else
            let soundTypes: [SoundIdentifier.SoundType] = [.gunshot]
            #endif
            let soundIdentifyingSubject = try soundIdentifier.startDetectingSounds(
                soundTypes: soundTypes,
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
                LogManager.log(.debug, module: .drillRecording, message: "Detected sound of type: \(detectedSoundInfo.soundType.identifier), confidence: \(detectedSoundInfo.confidence)")
                self.handleDetectedSound(detectedSoundInfo)
            }

            do {
                try startRecordingAudioIfNeeded()
                
                state = .recording
                startDate = Date()
                
                #if os(watchOS)
                HapticFeedbackGenerator.generateFeedback(.start)
                #else
                HapticFeedbackGenerator.generateFeedback(.warning)
                #endif
                
            } catch {
                LogManager.log(.error, module: .drillRecording, message: "Failed to start recording audio with error: \(error)")
                stopRecording()
                self.error = error
            }
        } catch {
            LogManager.log(.error, module: .drillRecording, message: "Failed to start identifying sounds with error: \(error)")
            stopRecording()
            self.error = error
        }
    }
    
    func stopRecording() {
        isPersistingData = true

        soundIdentifier.stopDetectingSounds()
        audioRecorder.stopRecording()
        
        soundIdentifyingCancellable?.cancel()
        timerCancellable?.cancel()
        
        persistData(in: modelContext, startDate: startDate, drillEntries: drillEntries)

        isPersistingData = false
        state = .summary
    }
    
    #if !os(watchOS)
    @MainActor func submit(for tournament: Tournament, user: UserInfo) async {
        guard let tournamentEntry else {
            return
        }

        do {
            try await firestoreService.submit(entry: tournamentEntry, for: tournament, as: user)
        } catch {
            LogManager.log(.error, module: .drillRecording, message: "Failed to submit entry: \(tournamentEntry) with error: \(error)")
            self.error = error
        }
    }
    #endif
    
    func deleteRecordedDrill() throws {
        guard let drill else {
            return
        }
        
        do {
            try modelContext.deleteDrill(drill)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Private Methods
    
    private func startRecordingAudioIfNeeded() throws {
        guard configuration.shouldRecordAudio else {
            return
        }
        
        do {
            let recordingURL = try AudioRecordingPathGenerator.pathForRecording(at: startDate)
            
            do {
                try audioRecorder.startRecording(audioURL: recordingURL)
            } catch {
                LogManager.log(.fault, module: .drillRecording, message: "Failed to start recording audio at: \(recordingURL) with error: \(error)")
                throw error
            }
        } catch {
            LogManager.log(.fault, module: .drillRecording, message: "Failed to generate recording for audio with error: \(error)")
            throw error
        }
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
        
        if configuration.maxShots > 0, drillEntries.count == configuration.maxShots {
            stopRecording()
        }
    }
    
    private func persistData(
        in modelContext: ModelContext,
        startDate: Date,
        drillEntries: [DrillEntry]
    ) {
        if let tournament {
            guard let currentUser else {
                self.error = LocalizedErrorInfo(errorDescription: "Failed to save submission", recoverySuggestion: "Please log in and try again")
                return
            }
            
            let tournamentEntry = TournamentEntry(
                tournamentId: tournament.id,
                userId: currentUser.id,
                date: startDate,
                sounds: drillEntries
            )
            LogManager.log(.info, module: .drillRecording, message: "Did create tournament entry: \(tournamentEntry)")
            self.tournamentEntry = tournamentEntry
            return
        }
        
        do {
            if let savedDrill = try saveDrillsSessionsContainer(
                in: modelContext,
                startDate: startDate,
                drillEntries: drillEntries
            ) {
                LogManager.log(.info, module: .drillRecording, message: "Did create drill entry: \(savedDrill)")
                drill = savedDrill
            } else {
                LogManager.log(.info, module: .drillRecording, message: "Did not save drill entry")
            }
            
        } catch {
            self.error = error
        }
    }
    
    @discardableResult
    private func saveDrillsSessionsContainer(
        in modelContext: ModelContext,
        startDate: Date,
        drillEntries: [DrillEntry]
    ) throws -> Drill? {
        guard drillEntries.isEmpty == false else {
            LogManager.log(.trace, module: .drillRecording, message: "No entries, will not create drill entry")
            return nil
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
            
            let drill = Drill(date: startDate, sounds: drillEntries, recordingConfiguration: configuration)
            container.addDrills([drill])
            
            return drill
        } catch {
            LogManager.log(.error, module: .drillRecording, message: "Failed to fetch container for date: \(containerFormattedDate) with error: \(error)")
            throw error
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
