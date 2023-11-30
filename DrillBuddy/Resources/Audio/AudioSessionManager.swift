//
//  AudioSessionManager.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-16.
//

import AVFoundation
import Foundation

class AudioSessionManager {
    /// Configures and activates an AVAudioSession.
    ///
    /// If this method throws an error, it calls `stopAudioSession` to reverse its effects.
    class func startAudioSession(
        category: AVAudioSession.Category,
        mode: AVAudioSession.Mode = .default,
        options: AVAudioSession.CategoryOptions = [],
        allowHapticsAndSystemSoundsDuringRecording: Bool = true
    ) throws {
        stopAudioSession()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(category, mode: mode)
            try audioSession.setActive(true)
            
            try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(allowHapticsAndSystemSoundsDuringRecording)
        } catch {
            LogManager.log(.error, module: .audioSessionManager, message: "Failed to start audio session with error: \(error)")
            stopAudioSession()
            throw error
        }
    }
    
    /// Deactivates the app's AVAudioSession.
    class func stopAudioSession() {
        autoreleasepool {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch {
                LogManager.log(.error, module: .audioSessionManager, message: "Failed to stop audio session with error: \(error)")
            }
        }
    }
}
