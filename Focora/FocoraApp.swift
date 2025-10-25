//
//  FocoraApp.swift
//  Focora
//
//  Created by MacBoock on 21.10.2025.
//

import SwiftUI

@main
struct FocoraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

