//
//  View+Extension.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-22.
//

import SwiftUI

// MARK: - Preview

extension View {
    var isInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

// MARK: - Error Presenting

extension View {
    func errorAlert(error: Binding<Error?>, cancelButtonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedErrorInfo(error: error.wrappedValue)
        
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(cancelButtonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.failureReason ?? error.recoverySuggestion ?? error.errorDescription ?? "Unknown error")
        }
    }
}
