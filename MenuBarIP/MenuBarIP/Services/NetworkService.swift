//
//  NetworkService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import Network
import AppKit
import Factory

class NetworkService: ServiceBase, ApiCallable, NetworkServiceType {
    @Injected(\.ipService) private var ipService
    @Injected(\.ipApiService) private var ipApiService
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    private var currentTimer: Timer? = nil
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
            
            if (self.appState.network.status != newStatus
                || self.appState.network.activeNetworkInterfaces != newNetworkInterfaces) {
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
                            isDisconnected: updatedStatus != .on)
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
        startConnectionHealthMonitoring()
        addSystemDidWakeHandler()
    }
    
    func getCurrentIp() {
        lock.lock()
        Task {
            do {
                let localIp = self.ipService.getLocalIp()
                
                await MainActor.run { updateStatus(isObtainingIp: true) }
                
                // Fixes SSL errors after network changes
                try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                
                var isIpObtained = false
                
                while !isIpObtained && self.appState.userData.ipApis.contains(where: {$0.isActive()}) {
                    let updatedIpResult = await self.ipService.getPublicIpAsync(
                        ipApiUrl: nil, withInfo: true)
                    
                    if (updatedIpResult.success) {
                        isIpObtained = true
                        await MainActor.run { updateStatus(publicIpInfo: updatedIpResult.result) }
                    }
                }
                
                if (!isIpObtained) {
                    await MainActor.run { updateStatus(publicIpInfo: nil, allowPublicIpInfoNil: true) }
                }
                
                await MainActor.run { updateStatus(localIp: localIp, isObtainingIp: false) }
            }
        }
        lock.unlock()
    }
    
    func isUrlReachableAsync(url : String) async throws -> Bool {
        do {
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard (response as? HTTPURLResponse)?
                .statusCode == 200 else {
                return false
            }
            
            return true
        }
    }
    
    deinit {
        monitor.cancel()
        currentTimer?.invalidate()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    // MARK: Private functions
    
    private func startConnectionHealthMonitoring() {
        currentTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Constants.defaultCheckConnectionHealthInterval), repeats: true) {
            timer in
            Task {
                guard self.appState.network.status == .on else { return }
                
                do {
                    let currentHasInternetAccess = try await self.isUrlReachableAsync(url: self.appState.userData.internetCheckUrl)
                    
                    if (!currentHasInternetAccess) {
                        self.updateStatus(publicIpInfo: nil, allowPublicIpInfoNil: true)
                    }
                    else if (self.appState.network.publicIpInfo == nil) {
                        self.ipApiService.reactivateIpApis()
                        self.getCurrentIp()
                    }
                    
                    self.updateStatus(hasInternetAccess: currentHasInternetAccess)
                }
                catch {
                    self.updateStatus(publicIpInfo: nil, hasInternetAccess: false, allowPublicIpInfoNil: true)
                }
            }
        }
    }
    
    private func activateIpApis() {
        for index in 0...self.appState.userData.ipApis.count - 1 {
            self.appState.userData.ipApis[index].active = true
        }
    }
    
    private func addSystemDidWakeHandler() {
        let center = NSWorkspace.shared.notificationCenter
        
        center.addObserver(self,
                           selector: #selector(systemDidWake),
                           name: NSWorkspace.didWakeNotification,
                           object: nil)
    }
    
    @objc private func systemDidWake() {
        if (appState.network.publicIpInfo == nil) {
            getCurrentIp()
        }
    }
    
    private func updateStatus(
        currentStatus: NetworkStatusType? = nil,
        publicIpInfo: IpInfo? = nil,
        localIp: String? = nil,
        activeNetworkInterfaces: [NetworkInterface]? = nil,
        isDisconnected: Bool? = nil,
        isObtainingIp: Bool? = nil,
        hasInternetAccess: Bool? = nil,
        allowPublicIpInfoNil: Bool = false) {
        DispatchQueue.main.async {
            if (currentStatus != nil) {
                self.appState.network.status = currentStatus!
                self.activateIpApis()
            }
                
            if (publicIpInfo != nil || allowPublicIpInfoNil) {
                self.appState.network.publicIpInfo = publicIpInfo ?? nil
            }
            
            if (localIp != nil) {
                self.appState.network.localIp = localIp
            }
                
            if (isObtainingIp != nil) {
                self.appState.network.isObtainingIp = isObtainingIp!
            }
            
            if (hasInternetAccess != nil) {
                self.appState.network.hasInternetAccess = hasInternetAccess!
            }
            
            if (activeNetworkInterfaces != nil) {
                self.appState.network.activeNetworkInterfaces = activeNetworkInterfaces!
            }
            
            if (isDisconnected != nil && isDisconnected!) {
                self.appState.network.publicIpInfo = nil
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
