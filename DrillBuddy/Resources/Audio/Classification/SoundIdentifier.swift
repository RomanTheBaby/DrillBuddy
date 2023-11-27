//
//  SoundIdentifier.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-16.
//

import Combine
import Foundation
import SoundAnalysis
import OSLog

class SoundIdentifier {
    
    // MARK: - SoundIdentifier
    
    enum SoundIdentifierError: Error {
        case audioTypeVerificationFailed
    }
    
    // MARK: - SoundType
    
    enum SoundType: String, CaseIterable {
        case clapping = "clapping"
        case fingerSnapping = "finger_snapping"
        case gunshot = "gunshot_gunfire"
        case silence = "silence"
        
        var identifier: String {
            rawValue
        }
    }
    
    struct DetectedSoundInfo {
        var soundType: SoundType
        var confidence: Double
        var timeRange: CMTimeRange
    }
    
    // MARK: - Public Properties
    
    private(set) var isIdentifyingSounds = false
    
    // MARK: - Private Properties

    private let audioClassifier: AudioClassifier
    private var detectionCancellable: AnyCancellable?
    
    private var subject = PassthroughSubject<DetectedSoundInfo, Never>()
    
    // MARK: - Init

    init(audioClassifier: AudioClassifier = AudioClassifier()) {
        self.audioClassifier = audioClassifier
    }
    
    // MARK: - Public Properties
    
    /// Classifies system audio input using the built-in classifier.
    ///
    /// - Parameters:
    ///   - soundTypes: Types of sound that should be detected
    ///   - minRequiredConfidence: confidence that classification must meet to be reported
    ///   - inferenceWindowSize: The amount of audio, in seconds, to account for in each
    ///   classification prediction. As this value grows, the accuracy may increase for longer sounds that
    ///   need more context to identify. However, delays also increase between the moment a sound
    ///   occurs and the moment that a sound produces a classification. This is because the system needs
    ///   to collect enough audio to gather the amount of context necessary to produce a prediction.
    ///   Increased accuracy is a trade-off for the responsiveness of a live classification app.
    ///   - overlapFactor: A ratio that indicates what part of an audio window overlaps with an
    ///   adjacent audio window. A value of 0.5 indicates that the audio for two consecutive predictions
    ///   overlaps so that the last 50% of the first duration serves as the first 50% of the second
    ///   duration. The factor determines the stride between consecutive durations of audio that produce
    ///   sound classification. As the factor increases, the stride decreases. As the stride decreases, the
    ///   system produces more predictions. So, at the computational expense of producing more predictions,
    ///   decreasing the stride by raising the overlap factor can improve perceived responsiveness.
    func startDetectingSounds(
        soundTypes: [SoundType],
        minRequiredConfidence: Double = 0.8,
        inferenceWindowSize: Double = 3,
        overlapFactor: Double = 0.4
    ) throws -> PassthroughSubject<DetectedSoundInfo, Never> {
        let validSoundTypes = validSoundTypes(from: soundTypes)
        
        guard validSoundTypes.isEmpty == false else {
            throw SoundIdentifierError.audioTypeVerificationFailed
        }
        
        if isIdentifyingSounds {
            stopDetectingSounds()
        }
        
        isIdentifyingSounds = true
        
        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()
        detectionCancellable = classificationSubject
          .receive(on: DispatchQueue.main)
          .sink(
            receiveCompletion: { _ in
                self.isIdentifyingSounds = false
            },
            receiveValue: { [weak self] classificationResult in
                guard let self else {
                    return
                }
                
                for soundType in validSoundTypes {
                    guard let classification = classificationResult.classification(forIdentifier: soundType.identifier) else {
                        Logger.soundIdentifier.error("no classification for \(soundType.identifier), got: \(classificationResult.classifications.map(\.identifier))")
                        continue
                    }
                    
                    guard classification.confidence > minRequiredConfidence else {
                        if classification.confidence > 0.1 {
                            Logger.soundIdentifier.trace("confidence requirements not met for audio type: \(classification.identifier), confidence: \(classification.confidence)")
                        }
                        continue
                    }
                    let soundInfo = DetectedSoundInfo(
                        soundType: soundType,
                        confidence: classification.confidence,
                        timeRange: classificationResult.timeRange
                    )
                    self.subject.send(soundInfo)
                }
            })
        
        audioClassifier.startSoundClassification(
            subject: classificationSubject,
            inferenceWindowSize: inferenceWindowSize,
            overlapFactor: overlapFactor
        )
        return subject
    }
    
    func stopDetectingSounds() {
        audioClassifier.stopSoundClassification()
        detectionCancellable?.cancel()
        detectionCancellable = nil
        subject.send(completion: .finished)
        isIdentifyingSounds = false
    }
    
    // MARK: - Private Methods
    
    /// Emits the set of labels producible by sound classification.
    ///
    ///  - Returns: The set of all labels that sound classification emits.
    private static func getAllPossibleLabels() throws -> Set<String> {
        let request = try SNClassifySoundRequest.makeShared()
        return Set<String>(request.knownClassifications)
    }
    
    private func validSoundTypes(from soundTypes: [SoundType]) -> [SoundType] {
        do {
            let validSoundLabels = try Self.getAllPossibleLabels()
            return soundTypes.filter { soundType in
                if validSoundLabels.contains(soundType.identifier) == false {
                    Logger.soundIdentifier.error("Not able to verify sound: \(soundType.identifier, privacy: .public)")
                    return false
                }
                return true
            }
        } catch {
            Logger.soundIdentifier.error("Failed to get possible sound labels with error: \(error, privacy: .public)")
            return []
        }
    }
}


// MARK: - Logger

private extension Logger {
    static let soundIdentifier = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DrillBuddy.AudioRecorder",
        category: String(describing: SoundIdentifier.self)
    )
}
