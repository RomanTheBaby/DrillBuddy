//
//  AudioRecorder.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-13.
//

import AVFoundation
import CoreAudio
import Combine
import Foundation
import SoundAnalysis

// NSObject inheritance required to conform to `AVAudioRecorderDelegate`
class AudioRecorder: NSObject, AVAudioRecorderDelegate, ObservableObject {
    
    // MARK: - RecorderSettings
    
    enum RecorderSettings {
        case `default`
        case custom([String: Any])
        
        fileprivate var dictionary: [String: Any] {
            switch self {
            case .default:
                return [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
            case .custom(let settings):
                return settings
            }
        }
    }
    
    // MARK: - Private Properties
    
    private(set) var audioRecorder: AVAudioRecorder?
    
    // MARK: - Public Methods
    
    @discardableResult
    func startRecording(audioURL: URL, settings: RecorderSettings = .default, isMeteringEnabled: Bool = false) throws -> AVAudioRecorder {
        LogManager.log(.trace, module: .audioRecorder, message: "Will record audio to: \(audioURL)")
        
        do {
            let audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings.dictionary)
            audioRecorder.isMeteringEnabled = isMeteringEnabled
            audioRecorder.prepareToRecord()
            audioRecorder.delegate = self
            audioRecorder.record()
            
            self.audioRecorder = audioRecorder
            return audioRecorder
        } catch {
            LogManager.log(.error, module: .audioRecorder, message: "Failed to start audio recording at: \(audioURL), with error: \(error) ")
            stopRecording()
            throw error
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            LogManager.log(.error, module: .audioRecorder, message: "Audio recorder finished recording unsuccessfully")
            stopRecording()
        }
    }

    /* if an error occurs while encoding it will be reported to the delegate. */
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            LogManager.log(.trace, module: .audioRecorder, message: "Audio recorder encode error did occur \(error)")
        }
    }
}

// MARK: - FileManager

private extension FileManager {
    var documentsDirectory: URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
