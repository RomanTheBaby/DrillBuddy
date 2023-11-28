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
    
    func startRecording(
        folderName: String,
        fileName: String,
        fileExtension: String = "m4a",
        settings: RecorderSettings = .default
    ) throws -> URL? {
        guard audioRecorder == nil else {
            LogManager.log(.warning, module: .audioRecorder, message: "Attemping to start recording while another recording is in progress. Aborting")
            return nil
        }

        let documentsDirectory = FileManager.default.documentsDirectory
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            let audioURL = folderURL.appendingPathComponent("\(fileName).\(fileExtension)")
            LogManager.log(.trace, module: .audioRecorder, message: "Will record audio to: \(audioURL)")

            do {
                try startRecording(audioURL: audioURL)
                return audioURL
            } catch {
                LogManager.log(.error, module: .audioRecorder, message: "Failed to start audio recording at: \(audioURL), with error: \(error) ")
                stopRecording()
                throw error
            }
            
        } catch {
            LogManager.log(.error, module: .audioRecorder, message: "Failed to create directory at url: \(folderURL) with error: \(error)")
            throw error
        }
    }
    
    @discardableResult
    func startRecording(audioURL: URL, settings: RecorderSettings = .default, isMeteringEnabled: Bool = false) throws -> AVAudioRecorder {
        LogManager.log(.trace, module: .audioRecorder, message: "Audio recorder will save new recording to: \(audioURL)")
        
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
