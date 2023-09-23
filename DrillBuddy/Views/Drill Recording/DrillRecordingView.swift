//
//  DrillRecordingView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import SwiftUI

struct DrillRecordingView: View {
    
    // MARK: - Properties
    
    var configuration: DrillRecordingConfiguration
    
    @Environment(\.dismiss) private var dismiss

    // MARK: - View
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Configuration: ")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("maxShots: \(configuration.maxShots)")
                Text("maxSessionDelay: \(configuration.maxSessionDelay)")
                Text("minimumSoundConfidenceLevel: \(configuration.minimumSoundConfidenceLevel)")
                Text("inferenceWindowSize: \(configuration.inferenceWindowSize)")
                Text("overlapFactor: \(configuration.overlapFactor)")
                Text("shouldRecordAudio: \(configuration.shouldRecordAudio ? "true" : "false")")
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)
            .shadow(radius: 5)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Previews

#Preview {
    DrillRecordingView(configuration: .default)
}
