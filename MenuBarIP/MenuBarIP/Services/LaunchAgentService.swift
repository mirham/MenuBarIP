//
//  LaunchAgentService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import ServiceManagement

final class LaunchAgentService: LaunchAgentServiceType {
    var isInstalled: Bool = false
    var status: SMAppService.Status { service.status }
    
    private let service = SMAppService.agent(plistName: Constants.launchAgentPlistName)
    private(set) var lastError: Error?
    private var desiredState = false
    
    init() {
        refresh()
    }
    
    func refresh() {
        isInstalled = (service.status == .enabled)
        desiredState = isInstalled
    }
    
    func setState(isInstalled: Bool) {
        desiredState = isInstalled
    }
    
    @discardableResult
    func apply() -> Bool {
        lastError = nil
        
        do {
            if desiredState {
                if service.status != .enabled {
                    try service.register()
                }
            } else if service.status == .enabled || service.status == .requiresApproval {
                try service.unregister()
            }
        } catch {
            lastError = error
        }
        
        refresh()
        
        return lastError == nil
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
