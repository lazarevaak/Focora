//
//  AppInfo.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 08.11.2025.
//

import Foundation
import AppKit

struct AppInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: NSImage?
}
