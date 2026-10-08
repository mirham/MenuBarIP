//
//  AppAppearance.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 08.10.2026.
//

import Foundation
import Observation
import AppKit
import SwiftUI

@MainActor
@Observable
final class AppAppearance {
    private(set) var colorScheme: ColorScheme = .light
    private var observation: NSKeyValueObservation?
    private var notificationTask: Task<Void, Never>?
    
    init() {
        refresh()
        
        observation = NSApplication.shared.observe(
            \.effectiveAppearance,
             options: [.new]) { [weak self] _, _ in
            Task { @MainActor in self?.refresh() }
        }
        
        notificationTask = Task { @MainActor [weak self] in
            let center = DistributedNotificationCenter.default()
            
            for await _ in center.notifications(
                named: Notification.Name(Constants.notificatinThemeChangedName)) {
                
                try? await Task.sleep(for: .milliseconds(100))
                
                self?.refresh()
            }
        }
    }
    
    // MARK: Private functions
    
    private func refresh() {
        let match = NSApplication.shared.effectiveAppearance
            .bestMatch(from: [.aqua, .darkAqua])
        let newScheme: ColorScheme = (match == .darkAqua)
            ? .dark : .light
        
        if colorScheme != newScheme {
            colorScheme = newScheme
        }
    }
}
