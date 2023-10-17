//
//  DrillRecordingConfiguration.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import Foundation

struct DrillRecordingConfiguration {
    /// Max shots that app should record in a session. After shots limit is reached, sessions should stop. 0 - unlimited
    var maxShots: Int = 0
    
    /// Max delay in seconds before start of sessions
    var maxSessionDelay: TimeInterval
    
    /// How confident the app should be in hearing a correct noise
    var minimumSoundConfidenceLevel: Double = 0.7
    
    ///    The amount of audio, in seconds, to account for in each
    ///   classification prediction. As this value grows, the accuracy may increase for longer sounds that
    ///   need more context to identify. However, delays also increase between the moment a sound
    ///   occurs and the moment that a sound produces a classification. This is because the system needs
    ///   to collect enough audio to gather the amount of context necessary to produce a prediction.
    ///   Increased accuracy is a trade-off for the responsiveness of a live classification app.
    var inferenceWindowSize: Double = 3
    
    ///    A ratio that indicates what part of an audio window overlaps with an
    ///   adjacent audio window. A value of 0.5 indicates that the audio for two consecutive predictions
    ///   overlaps so that the last 50% of the first duration serves as the first 50% of the second
    ///   duration. The factor determines the stride between consecutive durations of audio that produce
    ///   sound classification. As the factor increases, the stride decreases. As the stride decreases, the
    ///   system produces more predictions. So, at the computational expense of producing more predictions,
    ///   decreasing the stride by raising the overlap factor can improve perceived responsiveness.
    var overlapFactor: Double = 0.4
    
    /// If app should save recording of session as separate audio file
    var shouldRecordAudio: Bool
}

extension DrillRecordingConfiguration {
    static let `default` = DrillRecordingConfiguration(
        maxShots: 0,
        maxSessionDelay: 1,
        minimumSoundConfidenceLevel: 0.7,
        inferenceWindowSize: 0.3,
        overlapFactor: 0.4,
        shouldRecordAudio: false
    )
}
