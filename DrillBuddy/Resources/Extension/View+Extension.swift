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

private struct LocalizedAlertError: LocalizedError {
    var errorDescription: String
    var recoverySuggestion: String?

    init?(error: Error?) {
        guard let error else {
            return nil
        }
        let localizedError = error as? LocalizedError
        errorDescription = localizedError?.errorDescription ?? error.localizedDescription
        recoverySuggestion = localizedError?.recoverySuggestion
    }
}

extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? error.errorDescription)
        }
    }
}
