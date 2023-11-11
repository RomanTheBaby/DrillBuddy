//
//  DrillParameterInfoFactory.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-11.
//

import Foundation

struct DrillParameterInfoFactory: Identifiable {
    
    // MARK: - Properties
    
    let id: String
    
    let title: String
    let description: String
    
    // MARK: - Init
    
    init<T>(keyPath: KeyPath<DrillRecordingConfiguration, T>) {
        let title = Self.title(for: keyPath)
        let description = Self.description(for: keyPath)
        self.id = "title: \(title)\ndescription: \(description)"
        self.title = title
        self.description = description
    }
    
//    init(keypath: KeyPath<DrillRecordingConfiguration, Double>) {
//        self.title = DrillParameterInfoFactory.title(for: keypath)
//        self.description = DrillParameterInfoFactory.description(for: keypath)
//    }
//    
//    init(keypath: KeyPath<DrillRecordingConfiguration, Int>) {
//        self.title = DrillParameterInfoFactory.title(for: keypath)
//        self.description = DrillParameterInfoFactory.description(for: keypath)
//    }
//    
//    init(keypath: KeyPath<DrillRecordingConfiguration, Bool>) {
//        self.title = DrillParameterInfoFactory.title(for: keypath)
//        self.description = DrillParameterInfoFactory.description(for: keypath)
//    }
    
    // MARK: - Private Methods
    
    private static func title<T>(for keyPath: KeyPath<DrillRecordingConfiguration, T>) -> String {
        switch keyPath {
        case \.inferenceWindowSize:
            return "Inference Window Size"
        case \.maxShots:
            return "Max Shots"
        case \.maxSessionDelay:
            return "Max Session Delay"
        case \.minimumSoundConfidenceLevel:
            return "Minimum Sound Confidence Level"
        case \.shouldRecordAudio:
            return "Should Record Audio"
        case \.overlapFactor:
            return "Overlap Factor"
        default:
            return "Unknwon parameter"
        }
    }
    
    private static func description<T>(for keyPath: KeyPath<DrillRecordingConfiguration, T>) -> String {
        switch keyPath {
        case \.inferenceWindowSize:
            return """
                   \tThe amount of audio, in seconds, to account for in each classification prediction.
                   As this value grows, the accuracy may increase for longer sounds that \
                   need more context to identify. However, delays also increase between the moment a sound \
                   occurs and the moment that a sound produces a classification.
                   \tThis is because the system needs to collect enough audio to gather the \
                   amount of context necessary to produce a prediction.
                   \tIncreased accuracy is a trade-off for the responsiveness of a live classification app.
                   """
        case \.maxShots:
            return "\tNumber of maximum shots that should be recorded. As soon as the number is reached recording will stop automatically, unless in a tournament."
        case \.maxSessionDelay:
            return """
                \tMax delay, in seconds, which app will wait before starting recording the drill. \
                Start delay will always be ranging from 1 to the provided max session delay value.
            """
        case \.minimumSoundConfidenceLevel:
            return "How confident machine learning model should be that it heard a gunshot, value can range from 0.1 - 1, where 1 is 100% confident. Outside factors, such as background noise, can affect how confident the algorythm is, because of this we recoment keeping the value at around 0.7 - 0.8"
        case \.shouldRecordAudio:
            return """
                \tIf checked, app will record audio of the drill into a separate audio file. \
                You will be able to listen to the recording at any time. If drill is deleted, audio file will be deleted as well.
                """
        case \.overlapFactor:
            return """
                   \tA ratio that indicates what part of an audio window overlaps with an adjacent audio window. \
                   A value of 0.5 indicates that the audio for two consecutive predictions \
                   overlaps so that the last 50% of the first duration serves as the first 50% of the second duration.
                   \tThe factor determines the stride between consecutive durations of audio that produce \
                   sound classification. As the factor increases, the stride decreases. As the stride decreases, the \
                   system produces more predictions.
                   \tSo, at the computational expense of producing more predictions, \
                   decreasing the stride by raising the overlap factor can improve perceived responsiveness.
                   """
        default:
            return "Unknwon parameter"
        }
    }
}
