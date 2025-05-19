//
//  ContainerExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

import Factory

// MARK: DI registrations

extension Container {
    // MARK: Services registrations
    
    var networkService: Factory<NetworkServiceType> {
        Factory(self) { NetworkService() }
    }
    
    var ipService: Factory<IpServiceType> {
        Factory(self) { IpService() }
    }
    
    var ipApiService: Factory<IpApiServiceType> {
        Factory(self) { IpApiService() }
    }
    
    var launchAgentService: Factory<LaunchAgentServiceType> {
        Factory(self) { LaunchAgentService() }
    }
}
