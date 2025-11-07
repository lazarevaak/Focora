//
//  Gradients.swift
//  Focora
//
//  Created by Alexandra Lazareva on 07.11.2025.
//

internal import SwiftUI

internal enum FocoraGradients {
    static let primary = LinearGradient(
        colors: [
            Color(red: 0.72, green: 0.82, blue: 0.93),
            Color(red: 0.80, green: 0.75, blue: 0.90)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lightPrimary = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.67, green: 0.78, blue: 0.87),
            Color(red: 0.80, green: 0.75, blue: 0.90)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let topBarBackground = LinearGradient(
        colors: [
            Color(red: 0.12, green: 0.13, blue: 0.16),
            Color(red: 0.09, green: 0.10, blue: 0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let windowBackground = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.08, blue: 0.10),
            Color(red: 0.12, green: 0.13, blue: 0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let lightOverlay = Color.white.opacity(0.05)
}
