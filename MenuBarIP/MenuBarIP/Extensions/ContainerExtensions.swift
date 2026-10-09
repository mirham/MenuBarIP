//
//  ContainerExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

import Factory

// MARK: DI registrations

extension Container {
    
    // MARK: App state
    
    @MainActor
    var appState: Factory<AppState> {
        self { @MainActor in AppState() }
            .singleton
    }
    
    @MainActor
    var appAppearance: Factory<AppAppearance> {
        self { @MainActor in AppAppearance() }
            .singleton
    }
    
    // MARK: Windows management
    
    @MainActor
    var windowManager: Factory<WindowManager> {
        Factory(self) { @MainActor in WindowManager() }
            .singleton
    }
    
    @MainActor
    var windowRegistry: Factory<WindowRegistry> {
        Factory(self) {@MainActor in WindowRegistry(manager: self.windowManager()) }
            .singleton
    }
    
    
    // MARK: Services registrations
    
    @MainActor
    var networkService: Factory<NetworkServiceType> {
        Factory(self) { @MainActor in  NetworkService() }
            .singleton
    }
    
    @MainActor
    var ipService: Factory<IpServiceType> {
        Factory(self) { @MainActor in IpService() }
            .singleton
    }
    
    @MainActor
    var ipApiService: Factory<IpApiServiceType> {
        Factory(self) { @MainActor in IpApiService() }
            .singleton
    }
    
    @MainActor
    var executiveService: Factory<ExecutiveServiceType> {
        Factory(self) { @MainActor in ExecutiveService() }
            .singleton
    }
    
    @MainActor
    var loggingService: Factory<LoggingServiceType> {
        Factory(self) { @MainActor in LoggingService() }
            .singleton
    }
    
    @MainActor
    var launchAgentService: Factory<LaunchAgentServiceType> {
        Factory(self) { @MainActor in LaunchAgentService() }
            .singleton
    }
}
