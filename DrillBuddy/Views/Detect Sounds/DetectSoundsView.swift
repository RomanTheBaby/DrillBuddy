//
//  DetectSoundsView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-14.
//

import SwiftUI

struct DetectSoundsView: View {
    
    var confidence: Double
    var label: String = ""
    var numberOfBars: Int = 30
    var maxBarSize: CGSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    var labelForBar: ((_ barIndex: Int) -> any View)? = nil
    
    // MARK: - View
    
    var body: some View {
        VStack {
            generateMeter(confidence: confidence, numberOfBars: numberOfBars)
            if label.isEmpty == false {
                Text(label)
                    .padding(.top, 4)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.blue)
                .opacity(0.2)
        )
    }
    
    // MARK: - Private Methods
    
    private func generateMeter(confidence: Double, numberOfBars: Int) -> some View {
        let barColors = generateConfidenceMeterBarColor(numberOfBars: numberOfBars)
        let confidencePerBar = 1 / Double(numberOfBars)
        let litBarsCount = Int(confidence / confidencePerBar)
        let litBarOpacities = [Double](repeating: 1, count: litBarsCount)
        let unlitBarOpacities = [Double](repeating: 0.2, count: numberOfBars - litBarsCount)
        let barOpacities = litBarOpacities + unlitBarOpacities
        
        return VStack(spacing: 2) {
            ForEach(0..<numberOfBars, id: \.self) { barIndex in
                ZStack {
                    Rectangle()
                        .foregroundStyle(barColors[numberOfBars - 1 - barIndex])
                        .opacity(barOpacities[numberOfBars - 1 - barIndex])
                    if let barLabel = labelForBar?(barIndex) {
                        AnyView(barLabel)
                    }
                }
            }
        }.animation(.easeInOut, value: confidence)
    }
    
    private func generateConfidenceMeterBarColor(numberOfBars: Int) -> [Color] {
        let greenBarsCount = Int(Double(numberOfBars) / 3.0)
        let yellowBarsCount = Int(Double(numberOfBars) * 2 / 3.0) - greenBarsCount
        let redBarsCount = Int(numberOfBars - yellowBarsCount)
        
        return [Color](repeating: .green, count: greenBarsCount)
            + [Color](repeating: .yellow, count: yellowBarsCount)
            + [Color](repeating: .red, count: redBarsCount)
    }
}

// MARK: - Preview

#Preview {
    DetectSoundsView(confidence: 0.5)
        .padding()
}

#Preview("With Labels") {
    DetectSoundsView(
        confidence: 0.5,
        label: "Test Label",
        labelForBar: { barIndex in
            Text("\(barIndex)")
        }
    )
    .padding()
}
