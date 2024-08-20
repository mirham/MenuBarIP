//
//  NetworkStatusService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import Network

class NetworkStatusService: ServiceBase, ApiCallable {
    private let ipService = IpService.shared
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    private let lock = NSLock()
    
    override init() {
        super.init()
        
        monitor.pathUpdateHandler = { path in
            var newStatus = NetworkStatusType.unknown
            var newNetworkInterfaces = [NetworkInterface]()
            
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = networkInterface.asNetworkInterface()
                newNetworkInterfaces.append(networkInterfaceInfo)
            }
            
            switch path.status {
                case .satisfied:
                    newStatus = newNetworkInterfaces.contains(where: {$0.isPhysical})
                    ? NetworkStatusType.on
                    : NetworkStatusType.wait
                case .requiresConnection:
                    newStatus = NetworkStatusType.wait
                default:
                    newStatus = NetworkStatusType.off
            }
            
            if (self.appState.network.status != newStatus || self.appState.network.activeNetworkInterfaces != newNetworkInterfaces) {
                let updatedStatus = newStatus
                let updatedNetworkInterfaces = newNetworkInterfaces
                
                if (newStatus == .on) {
                    self.getCurrentIp()
                }
                
                Task {
                    await MainActor.run {
                        self.updateStatus(
                            currentStatus: updatedStatus,
                            activeNetworkInterfaces: updatedNetworkInterfaces,
                            disconnected: updatedStatus != .on)
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: Private functions
    
    private func getCurrentIp() {
        lock.lock()
        Task {
            do {
                let localIp = self.ipService.getLocalIp()
                
                await MainActor.run { updateStatus(obtainingIp: true) }
                
                // Fixes SSL errors after network changes
                try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                
                var ipNotObtained = true
                
                while ipNotObtained && self.appState.userData.ipApis.contains(where: {$0.isActive()}) {
                    let updatedIpResult = await self.ipService.getPublicIpAsync()
                    
                    if (updatedIpResult.success) {
                        ipNotObtained = false
                        await MainActor.run { updateStatus(publicIpInfo: updatedIpResult.result) }
                    }
                }
                
                if (ipNotObtained) {
                    await MainActor.run { updateStatus(publicIpInfo: nil, allowPublicIpInfoNil: true) }
                }
                
                await MainActor.run { updateStatus(localIp: localIp, obtainingIp: false) }
            }
        }
        lock.unlock()
    }
    
    private func updateStatus(
        currentStatus: NetworkStatusType? = nil,
        publicIpInfo: IpInfoBase? = nil,
        localIp: String? = nil,
        activeNetworkInterfaces: [NetworkInterface]? = nil,
        disconnected: Bool? = nil,
        obtainingIp: Bool? = nil,
        allowPublicIpInfoNil: Bool = false) {
            DispatchQueue.main.async {
                if (currentStatus != nil) {
                    self.appState.network.status = currentStatus!
                }
                
                if (publicIpInfo != nil || allowPublicIpInfoNil) {
                    self.appState.network.publicIpInfo = publicIpInfo ?? nil
                }
                
                if (localIp != nil) {
                    self.appState.network.localIp = localIp
                }
                
                if (obtainingIp != nil) {
                    self.appState.network.obtainingIp = obtainingIp!
                }
                
                
                if (activeNetworkInterfaces != nil) {
                    self.appState.network.activeNetworkInterfaces = activeNetworkInterfaces!
                }
                
                if (disconnected != nil && disconnected!) {
                    self.appState.network.publicIpInfo = nil
                }
                
                self.appState.objectWillChange.send()
            }
        }
}
