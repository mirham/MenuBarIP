//
//  LaunchAgentServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

import ServiceManagement

@MainActor
protocol LaunchAgentServiceType {
    var isInstalled: Bool { get }
    var isDesired: Bool { get }
    var hasPendingChange: Bool { get }
    var status: SMAppService.Status { get }
    var lastError: Error? { get }
    var persistedError: String? { get }
    
    func refresh()
    func setState(isInstalled: Bool)
    @discardableResult func apply() -> Bool
    func clearPersistedError()
    func openLoginItemsSettings()
    func removeLegacyAgent()
}

