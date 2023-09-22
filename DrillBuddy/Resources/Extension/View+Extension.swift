//
//  View+Extension.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import SwiftUI

extension View {
    var isInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
