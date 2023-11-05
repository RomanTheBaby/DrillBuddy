//
//  LoadingViewModifier.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import SwiftUI

struct LoadingViewModifier: ViewModifier {
    var isLoading: Bool
    var blurRadius: CGFloat = 6

    func body(content: Content) -> some View {
        if isLoading {
            content
                .blur(radius: blurRadius)
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                )
        } else {
            content
        }
    }
}

extension View {
    func loadingOverlay(
        isLoading: Bool,
        blurRadius: CGFloat = 6
    ) -> some View {
        modifier(
            LoadingViewModifier(
                isLoading: isLoading,
                blurRadius: blurRadius
            )
        )
    }
}
