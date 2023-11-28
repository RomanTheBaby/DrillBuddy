//
//  AudioRecordingPathGenerator.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-27.
//

import Foundation

// MARK: - PathGenerator

class AudioRecordingPathGenerator {
    
    class func path(for drill: Drill, createMissingDirectories: Bool = false) throws -> URL {
        try pathForRecording(at: drill.date, fileExtension: "m4a", createMissingDirectories: createMissingDirectories)
    }
    
    class func pathForRecording(at date: Date, fileExtension: String = "m4a", createMissingDirectories: Bool = true) throws -> URL {
        let folderName = DateFormatter.audioFolderName.string(from: date)
        let fileName = DateFormatter.audioFileName.string(from: date)
        
        let documentsDirectory = FileManager.default.documentsDirectory
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        
        let directoryExists = FileManager.default.fileExists(atPath: folderURL.relativePath, isDirectory: nil)
        
        if directoryExists == false {
            if createMissingDirectories == false {
                throw LocalizedErrorInfo(failureReason: "Unable to generate URL for recording, missing Intermediate Directories")
            } else {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
        }
        
        return folderURL.appendingPathComponent("\(fileName).\(fileExtension)")
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
