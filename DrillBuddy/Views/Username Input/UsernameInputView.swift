//
//  UsernameInputView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-31.
//

import SwiftUI

// MARK: - UsernameInputView

struct UsernameInputView: View {
    
    // MARK: Properties
    
    @State var username: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var isInputValid: Bool = false

    private var minLength: Int = 3
    private var maxLength: Int = 20
    
    private let firestoreService: FirestoreService = FirestoreService()
    
    
    /// In the future we should transition to using `Regex` instance,
    /// Sample:
    ///
    ///     let regex = try! Regex("\\A\\w{4,12}\\z")
    ///     try regex.wholeMatch(in: username)
    ///
    /// but that would require potential error handling, which we do not want at the moment
    private var usernamePredicate: NSPredicate
    
    private var lengthRequirementColor: Color {
        guard isLengthValid == false else {
            return .green
        }
        
        return .red
    }
    
    private var specialSymbolsRequirementColor: Color {
        guard isInputValid == false else {
            return .green
        }
        
        return isLengthValid ? .red : .primary
    }
    
    private var isLengthValid: Bool {
        guard isInputValid == false else {
            return true
        }
        
        return username.count >= minLength && username.count <= maxLength
    }
    
    // MARK: Init
    
    init(
        username: String = "",
        minLength: Int = 3,
        maxLength: Int = 20
    ) {
        self.usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "\\A\\w{\(minLength),\(maxLength)}\\z")
        self.username = username
        self.minLength = minLength
        self.maxLength = maxLength
    }
    
    // MARK: View
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                Text("• Length between \(minLength) and \(maxLength)")
                    .foregroundStyle(lengthRequirementColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("• Cannot contain special symbols")
                    .foregroundStyle(specialSymbolsRequirementColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("• Can contain any combination of the following:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\t• Uppercase and/or lowercase letters")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\t• numbers")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\t• _ symbol")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: .infinity, alignment: .leading)
            
            TextField("Enter username...", text: $username)
                .font(.system(.title, weight: .bold))
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .submitLabel(.done)
                .onSubmit {
                    guard isInputValid else {
                        return
                    }
                    
//                    NSUbiquitousKeyValueStore.default.username = username
//                    dismiss()
                    
                    Task {
                        _ = try await firestoreService.addUsername(username)
                        dismiss()
                    }
                }
                .onChange(of: username) {
                    username = String(username.replacingOccurrences(of: " ", with: "").prefix(maxLength))
                    isInputValid = usernamePredicate.evaluate(with: username)
                }
            
            Spacer()
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle.fill")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        UsernameInputView(maxLength: 10)
    }
}
