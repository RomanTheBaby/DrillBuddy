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
    
    let tournament: Tournament?
    let currentUser: UserInfo?
    private(set) var drillEntries: [DrillEntry] = []
    
    @Published var error: Error?
    @Published private(set) var showLoadingOverlay: Bool = false
    @Published private(set) var state: State
    @Published private(set) var lastDetectedSoundConfidenceLevel: Double = 0
    @Published private(set) var recordingStatistics: RecordingStatistics = .init()
    @Published private(set) var isPersistingData = false
    
    // MARK: - Private Properties
    
    private let configuration: DrillRecordingConfiguration
    private let audioRecorder: AudioRecorder
    private let soundIdentifier: SoundIdentifier
    
    #if !os(watchOS)
    private let firestoreService: FirestoreService = .init()
    #endif
    
    private let modelContext: ModelContext
    
    private var audioRecordingURL: URL?
    
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
        audioRecorder: AudioRecorder = .init(),
        soundIdentifier: SoundIdentifier = .init()
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
            let soundIdentifyingSubject = try soundIdentifier.startDetectingSounds(
                soundTypes: [.gunshot],//[.gunshot, .clapping, .fingerSnapping],
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
                self.error = error
            }
            
            state = .recording
            startDate = Date()
            
            #if os(watchOS)
            HapticFeedbackGenerator.generateFeedback(.start)
            #else
            HapticFeedbackGenerator.generateFeedback(.success)
            #endif
        } catch {
            Logger.drillRecording.error("Failed to start identifying sounds with error: \(error)")
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

        showLoadingOverlay = true
        do {
            try await firestoreService.submit(entry: tournamentEntry, for: tournament, as: user)
        } catch {
            Logger.drillRecording.error("Failed to submit entry: \(tournamentEntry) with error: \(error)")
            self.error = error
        }
        showLoadingOverlay = false
    }
    #endif
    
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
            guard let audioRecordingURL else {
                self.error = LocalizedErrorInfo(errorDescription: "Failed to record audio", recoverySuggestion: "Please try again")
                return
            }
            
            guard let currentUser else {
                self.error = LocalizedErrorInfo(errorDescription: "Failed to save submission", recoverySuggestion: "Please log in and try again")
                return
            }
            
            let tournamentEntry = TournamentEntry(
                tournamentId: tournament.id,
                userId: currentUser.id,
                date: startDate,
                sounds: drillEntries,
                recordingURL: audioRecordingURL
            )
            Logger.drillRecording.info("Did create tournament entry: \(tournamentEntry)")
            self.tournamentEntry = tournamentEntry
            return
        }
        
        do {
            if let savedDrill = try saveDrillsSessionsContainer(
                in: modelContext,
                startDate: startDate,
                drillEntries: drillEntries
            ) {
                Logger.drillRecording.info("Did create drill entry: \(savedDrill)")
            } else {
                Logger.drillRecording.info("Did not save drill entry")
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
            Logger.drillRecording.trace("No entries, will not create drill entry")
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
            
            let drill = Drill(date: startDate, sounds: drillEntries, recordingURL: audioRecordingURL)
            container.addDrills([drill])
            
            return drill
        } catch {
            Logger.drillRecording.error("Failed to fetch container for date: \(containerFormattedDate) with error: \(error)")
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


// MARK: - Logger

private extension Logger {
    static let drillRecording = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.DrillRecordingViewModel",
        category: String(describing: DrillRecordingViewModel.self)
    )
}
