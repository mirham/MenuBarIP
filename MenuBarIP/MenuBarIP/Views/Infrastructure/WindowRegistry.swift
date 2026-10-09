//
//  WindowRegistry.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit
import SwiftUI
import Factory

@MainActor
class WindowRegistry {
    private let manager: WindowManager
    private let appState: AppState = Container.shared.appState()
    
    init(manager: WindowManager) {
        self.manager = manager
        registerAll()
    }
    
    // MARK: Private functions
    
    private func registerAll() {
        manager.register(name: .settings) {
            NSHostingView(rootView: SettingsView())
        }
        manager.register(name: .publicIpLocation) {
            NSHostingView(rootView: PublicIpLocationView())
        }
        manager.register(name: .log) {
            NSHostingView(rootView: LogView(container: Container()))
        }
        manager.register(name: .info) {
            NSHostingView(rootView: InfoView())
        }
    }
}
