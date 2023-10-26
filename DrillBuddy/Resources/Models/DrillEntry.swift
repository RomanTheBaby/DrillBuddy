//
//  DrillEntry.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-24.
//

import Foundation


struct DrillEntry: Codable, Hashable {
    var time: TimeInterval
    var confidence: Double
}


extension Array where Element == DrillEntry {
    var averageSplit: TimeInterval {
        let shotTimes = map(\.time)
        let splits = shotTimes.dropLast(1).enumerated().map { index, time -> Double in
            shotTimes[index + 1] - time
        }
            
        return splits.reduce(0, +) / Double(splits.count)
    }
}
