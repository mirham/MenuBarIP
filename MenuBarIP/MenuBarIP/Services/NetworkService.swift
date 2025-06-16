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
    @Injected(\.executiveService) private var executiveService
    @Injected(\.loggingService) private var loggingSerevice
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    private var monitoringTask: Task<Void, Never>?
    
    override init() {
        super.init()
        
        startNetworkMonitoring()
        startConnectionHealthMonitoring()
        addSystemDidWakeHandler()
    }
    
    deinit {
        monitor.cancel()
        monitoringTask?.cancel()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    func isUrlReachableAsync(url : String) async throws -> Bool {
        do {
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = Constants.headHttpMethod
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            let result = (response as? HTTPURLResponse)?.statusCode == 200
            
            return result
        }
    }
    
    func refreshIpAddressesAsync() async {
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(true)
            .build())
        
        let prevPublicIp = appState.network.publicIp
        let localIp = ipService.getLocalIp()
        let publicIp = await fetchPublicIpAsync()
        
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(false)
            .withPublicIp(publicIp)
            .withLocalIp(localIp)
            .build())
        
        writeLog(publicIp: publicIp)
        executeScript(prevPublicIp: prevPublicIp, publicIp: publicIp)
    }
    
    // MARK: Private functions
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            let networkInterfaces = self.determineNetworkInterfaces(path: path)
            let status = self.determineNetworkStatusType(path: path, networkInterfaces: networkInterfaces)
            
            if (self.appState.network.isConnectionChanged (
                status: status,
                activeNetworkInterfaces: networkInterfaces)) {
                let updatedStatus = status
                let updatedNetworkInterfaces = networkInterfaces
                
                Task {
                    await self.updateStatusAsync(update: NetworkStateUpdateBuilder()
                        .withStatus(updatedStatus)
                        .withActiveNetworkInterfaces(updatedNetworkInterfaces)
                        .withIsDisconnected(updatedStatus != .on)
                        .build())
                    
                    if status == .on {
                        try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                        await self.refreshIpAddressesAsync()
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func startConnectionHealthMonitoring() {
        monitoringTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Constants.defaultCheckConnectionHealthIntervalNanoseconds)
                
                guard self.appState.network.status == .on else {
                    continue
                }
                
                let builder = NetworkStateUpdateBuilder()
                
                do {
                    let hasInternetAccess = try await isUrlReachableAsync(url: self.appState.userData.internetCheckUrl)
                    builder.withHasInternetAccess(hasInternetAccess)
                    
                    if hasInternetAccess && appState.network.publicIp == nil {
                        await refreshIpAddressesAsync()
                    }
                    
                    if !hasInternetAccess {
                        builder.withPublicIp(nil)
                    }

                    await updateStatusAsync(update: builder.build())
                } catch {
                    await updateStatusAsync(update: builder
                        .withHasInternetAccess(false)
                        .withPublicIp(nil)
                        .build())
                }
            }
        }
    }
    
    private func determineNetworkStatusType(
        path: NWPath,
        networkInterfaces: [NetworkInterface]) -> NetworkStatusType {
        switch path.status {
            case .satisfied:
                return networkInterfaces.contains(where: {$0.isPhysical})
                ? NetworkStatusType.on
                : NetworkStatusType.wait
            case .requiresConnection:
                return NetworkStatusType.wait
            default:
                return NetworkStatusType.off
        }
    }
    
    private func determineNetworkInterfaces(path: NWPath) -> [NetworkInterface] {
        var result = [NetworkInterface]()
        
        for networkInterface in path.availableInterfaces {
            let networkInterfaceInfo = networkInterface.asNetworkInterface()
            result.append(networkInterfaceInfo)
        }
        
        return result
    }
    
    private func addSystemDidWakeHandler() {
        let center = NSWorkspace.shared.notificationCenter
        
        center.addObserver(self,
                           selector: #selector(systemDidWake),
                           name: NSWorkspace.didWakeNotification,
                           object: nil)
    }
    
    private func fetchPublicIpAsync() async -> IpInfo? {
        while appState.network.hasInternetAccess && appState.userData.ipApis.contains(where: { $0.isActive() }) {
            let result = await ipService.getPublicIpAsync(ipApiUrl: nil, withInfo: true)
            
            if result.success {
                return result.result
            }
        }
        
        return nil
    }
    
    @objc private func systemDidWake() {
        if (appState.network.publicIp == nil) {
            Task {
                await refreshIpAddressesAsync()
            }
        }
    }
    
    private func updateStatusAsync(update: NetworkStateUpdate) async {
        await MainActor.run {
            appState.applyNetworkUpdate(update)
            appState.objectWillChange.send()
        }
    }
    
    private func writeLog(publicIp: IpInfo?) {
        guard appState.userData.enableLogging else { return }
        guard let ip = publicIp?.ipAddress else { return }
        
        loggingSerevice.info(ip, LogDestination.file)
    }
    
    private func executeScript(prevPublicIp: IpInfo?, publicIp: IpInfo?) {
        guard appState.userData.runScript else { return }
        guard let ip = publicIp?.ipAddress else { return }
        guard publicIp?.ipAddress != prevPublicIp?.ipAddress && publicIp != nil else { return }
        
        executiveService.executeScript(publicIp: ip)
    }
}
