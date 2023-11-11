//
//  DrillParameterInfoView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-11.
//

import SwiftUI

// MARK: - DrillParameterInfoView

struct DrillParameterInfoView: View {

    // MARK: Properties
    
    var infoFactory: DrillParameterInfoFactory
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(infoFactory.title)
                .font(.system(.title, weight: .bold))
            ScrollView {
                Text(infoFactory.description)
                    .font(.title3)
            }
            Button(action: {
                dismiss()
            }, label: {
                Text("Got it")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .toolbar {
            #if !os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle.fill")
                }
            }
            #endif
        }
    }
}

// MARK: - Previews

#Preview("Max Shots") {
    NavigationStack {
        DrillParameterInfoView(infoFactory: DrillParameterInfoFactory(keyPath: \.maxShots))
    }
}

#Preview("Max Session Delay") {
    NavigationStack {
        DrillParameterInfoView(infoFactory: DrillParameterInfoFactory(keyPath: \.maxSessionDelay))
    }
}

#Preview("Minimum Sound Confidence Level") {
    NavigationStack {
        DrillParameterInfoView(infoFactory: DrillParameterInfoFactory(keyPath: \.minimumSoundConfidenceLevel))
    }
}

#Preview("Inference Window Size") {
    NavigationStack {
        DrillParameterInfoView(infoFactory: DrillParameterInfoFactory(keyPath: \.inferenceWindowSize))
    }
}

#Preview("Overlap Factor") {
    NavigationStack {
        DrillParameterInfoView(infoFactory: DrillParameterInfoFactory(keyPath: \.overlapFactor))
    }
}

#Preview("Should Record Audio") {
    NavigationStack {
        DrillParameterInfoView(infoFactory: DrillParameterInfoFactory(keyPath: \.shouldRecordAudio))
    }
}
