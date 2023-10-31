//
//  HapticFeedbackGenerator.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-30.
//

import UIKit

#if os(watchOS)
import WatchKit
#endif

class HapticFeedbackGenerator {
    #if !os(watchOS)
    static func generateFeedback(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedbackType)
    }
    
    static func generateImpact(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.impactOccurred()
    }
    #endif
        
    #if os(watchOS)
    @MainActor static func generateFeedback(_ feedbackType: WKHapticType) {
        WKInterfaceDevice.current().play(.success)
    }
    #endif
}
