//
//  TagModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 06.11.2025.
//

import Foundation
internal import SwiftUI

struct TagModel: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String = TagModel.randomColorHex()) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Random Color
extension TagModel {
    static func randomColorHex() -> String {
        let hue = Double.random(in: 0...1)
        let saturation = Double.random(in: 0.35...0.55)
        let brightness = Double.random(in: 0.85...0.95)
        let color = Color(hue: hue, saturation: saturation, brightness: brightness)
        return color.toHex() ?? "#B59EE7"
    }
}

// MARK: - Color from hex
private extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        #if os(macOS)
        let nsColor = NSColor(self)
        #else
        let nsColor = UIColor(self)
        #endif
        guard let rgb = nsColor.usingColorSpace(.sRGB) else { return nil }
        let r = Int(round(rgb.redComponent * 255))
        let g = Int(round(rgb.greenComponent * 255))
        let b = Int(round(rgb.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
