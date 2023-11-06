//
//  DrillConfigurationView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-23.
//

import SwiftData
import SwiftUI

struct DrillConfigurationView: View {

    var showCloseButton = true
    var isConfigurationEditable = true
    @State var configuration: DrillRecordingConfiguration = .default
    
    @State private var showRecordingViewCover = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    var body: some View {
        VStack(spacing: 16) {
            List {
                #if os(watchOS)
                readyButton
                #endif
                
                Section {
                    ConfigurationStepperView(
                        title: "Min Confidence Level",
                        value: $configuration.minimumSoundConfidenceLevel,
                        stepRange: 0...1, 
                        step: 0.1
                    )
                    .disabled(!isConfigurationEditable)

                    ConfigurationStepperView(
                        title: "Inference Window Size",
                        value: $configuration.inferenceWindowSize,
                        stepRange: 0...10,
                        step: 0.1
                    )
                    .disabled(!isConfigurationEditable)
                    
                    ConfigurationStepperView(
                        title: "Overlap Factor",
                        value: $configuration.overlapFactor,
                        stepRange: 0...10,
                        step: 0.1
                    )
                    .disabled(!isConfigurationEditable)
                } header: {
                    Text("Sound Analysis")
                        .listRowInsets(EdgeInsets())
                }
                
                Section {
                    ConfigurationStepperView(
                        title: "Max Shots",
                        subtitle: "0 - no limits",
                        value: Binding(
                            get: {
                                Double(configuration.maxShots)
                            },
                            set: { newValue, _ in
                                configuration.maxShots = Int(newValue)
                            }
                        ),
                        stepRange: 0...10,
                        step: 1
                    )
                    .disabled(!isConfigurationEditable)
                    
                    ConfigurationStepperView(
                        title: "Max Start Delay",
                        value: $configuration.maxSessionDelay,
                        stepRange: 1...60,
                        step: 0.5
                    )
                    .disabled(!isConfigurationEditable)
                } header: {
                    Text("Shooting Session Config")
                        .listRowInsets(EdgeInsets())
                }
                
                Section {
                    HStack {
                        Toggle("Should Record Audio to file", isOn: $configuration.shouldRecordAudio)
                    }
                    .disabled(!isConfigurationEditable)
                } header: {
                    Text("Audio Recording")
                        .listRowInsets(EdgeInsets())
                }
                
                #if os(watchOS)
                    readyButton
                #endif
            }
            
            #if !os(watchOS)
            VStack(spacing: 8) {
                if isConfigurationEditable == false {
                    Text("Configuration cannot be edited")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
                readyButton
            }
            #endif
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Configure Session")
        .navigationBarTitleDisplayMode(.large)
        #if !os(watchOS)
        .fullScreenCover(isPresented: $showRecordingViewCover, content: {
            DrillRecordingView(
                customFinishAction: {
                    dismiss()
                },
                viewModel: DrillRecordingViewModel(modelContext: modelContext, configuration: configuration)
            )
        })
        #endif
        .toolbar {
            #if !os(watchOS)
            if showCloseButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                    }
                }
            }
            #endif
        }
    }
    
    private var readyButton: some View {
        #if os(watchOS)
        VStack {
            if isConfigurationEditable == false {
                Text("Configuration editing is disabled for now")
                    .font(.callout)
            }
            
            NavigationLink(
                destination: DrillRecordingView(
                    customFinishAction: {
                        dismiss()
                    },
                    viewModel: DrillRecordingViewModel(modelContext: modelContext, configuration: configuration)
                )
            ) {
                Text("Shooter Ready")
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .listRowBackground(Color.clear)
        #else
//        NavigationLink(
//            destination: DrillRecordingView(
//                customFinishAction: {
//                    dismiss()
//                },
//                viewModel: DrillRecordingViewModel(modelContext: modelContext, configuration: configuration)
//            )
//        ) {
//            Text("Shooter Ready")
//                .padding(8)
//                .frame(maxWidth: .infinity)
//        }
//        .buttonStyle(.borderedProminent)
//        .padding([.horizontal, .bottom])
//        .shadow(radius: 8)
        // Seems like adding Firebasepackage breaks NavigationLink here for some unknown reason
        Button(action: {
            showRecordingViewCover = true
        }, label: {
            Text("Shooter Ready")
                .padding(8)
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(.borderedProminent)
        .padding([.horizontal, .bottom])
        .shadow(radius: 8)
        
        #endif
    }
}

// MARK: - Configuration Stepper View

private struct ConfigurationStepperView: View {
    var title: String
    var subtitle: String? = nil
    @Binding var value: Double
    @State var stepRange: ClosedRange<Double>
    @State var step: Double
    
    var body: some View {
        #if os(watchOS)
        VStack {
            VStack(alignment: .leading) {
                Text(title)
                    .multilineTextAlignment(.center)
                if let subtitle, subtitle.isEmpty == false {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            Stepper(
                value.truncatingRemainder(dividingBy: 1) == 0 ? "\(value)" : String(format: "%.1f", value),
                value: $value,
                in: stepRange,
                step: step
            )
        }
        #else
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                if let subtitle, subtitle.isEmpty == false {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            TextField(title, value: $value, format: .number)
                .keyboardType(value.truncatingRemainder(dividingBy: 1) == 0 ? .numberPad : .decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 50)
            Stepper("", value: $value, in: stepRange, step: step)
                .labelsHidden()
        }
        #endif
    }
}

// MARK: - Preview

#Preview("Editable") {
    NavigationStack {
        DrillConfigurationView()
    }
}

#Preview("Non Editable") {
    NavigationStack {
        DrillConfigurationView(
            isConfigurationEditable: false,
            configuration: DrillRecordingConfiguration(maxShots: 3, maxSessionDelay: 3, shouldRecordAudio: true)
        )
    }
}
