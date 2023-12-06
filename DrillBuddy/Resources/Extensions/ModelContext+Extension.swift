//
//  ModelContext+Extension.swift
//  DrillBuddy
//
//  Created by Roman on 2023-12-05.
//

import Foundation
import SwiftData

extension ModelContext {
    
    func deleteDrill(_ drill: Drill) throws {
        try deleteRecording(for: drill)
        
        let container = drill.container
        delete(drill)
        
        let remainingDrills = container?.drills
            .filter {
                $0.isDeleted == false
            } ?? []
        
        if let container, remainingDrills.isEmpty {
            delete(container)
        }
    }
    
    private func deleteRecording(for drill: Drill) throws {
        guard let recordingURL = drill.recordingURL else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: recordingURL)
        } catch {
            LogManager.log(.error, module: .sessionsListView, message: "Failed to remove audio recording at url: \(recordingURL) with error: \(error)")
            throw error
        }
    }
}
