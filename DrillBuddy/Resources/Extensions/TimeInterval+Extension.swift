//
//  TimeInterval+Extension.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-16.
//

import Foundation


extension TimeInterval {
    var hour: Int {
        guard self.isNaN == false else {
            return 0
        }
        
        return Int((self / 3600).truncatingRemainder(dividingBy: 3600))
    }
    
    var minute: Int {
        guard self.isNaN == false else {
            return 0
        }
        
        return Int((self / 60).truncatingRemainder(dividingBy: 60))
    }
    
    var second: Int {
        guard isNaN == false else {
            return 0
        }
        
        return Int(truncatingRemainder(dividingBy: 60))
    }
    
    var millisecond: Int {
        guard self.isNaN == false else {
            return 0
        }
        
        return Int((self * 1000).truncatingRemainder(dividingBy: 1000))
    }
}
