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
        self { @MainActor in AppState() }.singleton
    }
    
    @MainActor
    var appAppearance: Factory<AppAppearance> {
        self { @MainActor in AppAppearance() }.singleton
    }
    
    // MARK: Windows management
    
    var windowManager: Factory<WindowManager> {
        Factory(self) {
            MainActor.assumeIsolated {
                WindowManager()
            }
        }.singleton
    }
    
    var windowRegistry: Factory<WindowRegistry> {
        Factory(self) {
            MainActor.assumeIsolated {
                WindowRegistry(manager: self.windowManager())
            }
        }.singleton
    }
    
    
    // MARK: Services registrations
    
    var networkService: Factory<NetworkServiceType> {
        Factory(self) { NetworkService() }
            .singleton
    }
    
    var ipService: Factory<IpServiceType> {
        Factory(self) { IpService() }
            .singleton
    }
    
    var ipApiService: Factory<IpApiServiceType> {
        Factory(self) { IpApiService() }
            .singleton
    }
    
    var executiveService: Factory<ExecutiveServiceType> {
        Factory(self) { ExecutiveService() }
            .singleton
    }
    
    var loggingService: Factory<LoggingServiceType> {
        Factory(self) { LoggingService() }
            .singleton
    }
    
    var launchAgentService: Factory<LaunchAgentServiceType> {
        Factory(self) { LaunchAgentService() }
            .singleton
    }
}
