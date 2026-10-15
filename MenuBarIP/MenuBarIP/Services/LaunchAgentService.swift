//
//  LaunchAgentService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import AppKit
import ServiceManagement
import Factory

final class LaunchAgentService: LaunchAgentServiceType {
    @Injected(\.appState) private var appState
    
    private let service = SMAppService.agent(plistName: Constants.launchAgentPlistName)
    
    private(set) var isInstalled = false
    private(set) var isDesired = false
    private(set) var hasPendingChange = false
    private(set) var lastError: Error?
    
    var status: SMAppService.Status { service.status }
    var persistedError: String? {
        appState.current.launchAgentError
    }
    
    init() {
        refresh()
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.hasPendingChange
                else { return }
                
                self.apply()
            }
        }
    }
    
    func refresh() {
        isInstalled = (service.status == .enabled)
        
        if !hasPendingChange {
            isDesired = isInstalled
        }
    }
    
    func setState(isInstalled newValue: Bool) {
        clearPersistedError()
        isInstalled = (service.status == .enabled)
        isDesired = newValue
        hasPendingChange = (newValue != isInstalled)
    }
    
    @discardableResult
    func apply() -> Bool {
        lastError = nil
        clearPersistedError()
        
        let enabling = isDesired
        
        do {
            if enabling {
                if service.status != .enabled {
                    try service.register()
                }
            } else if service.status == .enabled || service.status == .requiresApproval {
                try service.unregister()
            }
        } catch {
            lastError = error
            appState.current.launchAgentError = error.localizedDescription
        }
        
        hasPendingChange = false
        refresh()
        
        return lastError == nil
    }
    
    func clearPersistedError() {
        appState.current.launchAgentError = nil
    }
    
    func openLoginItemsSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
    
    func removeLegacyAgent() {
        guard let library = try? FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }
        
        let plistURL = library
            .appendingPathComponent(Constants.llaFolder)
            .appendingPathComponent(Constants.llaPlistName)
        
        guard FileManager.default.fileExists(atPath: plistURL.path)
        else { return }
        
        try? FileManager.default.removeItem(at: plistURL)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: Constants.llaExec)
        process.arguments = [
            Constants.llaRemove,
            Constants.llaAgentName
        ]
        
        try? process.run()
    }
}
