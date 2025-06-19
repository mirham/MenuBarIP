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
    private var publicIpRefreshingTask: Task<Void, Never>?
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
        publicIpRefreshingTask?.cancel()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    func isUrlReachableAsync(url : String) async throws -> Bool {
        guard !Task.isCancelled else {
            throw CancellationError()
        }
        
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = Constants.headHttpMethod
        request.timeoutInterval = Constants.callTimeoutSiteInSeconds
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                continuation.resume(returning: httpResponse.statusCode == 200)
            }
            task.resume()
        }
    }
    
    func refreshIpAddressesAsync() async {
        guard !Task.isCancelled else { return }
        
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
        
        guard !Task.isCancelled else { return }
        
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
                
                self.publicIpRefreshingTask?.cancel()
                
                self.publicIpRefreshingTask = Task {
                    await self.updateStatusAsync(update: NetworkStateUpdateBuilder()
                        .withStatus(updatedStatus)
                        .withActiveNetworkInterfaces(updatedNetworkInterfaces)
                        .withIsDisconnected(updatedStatus != .on)
                        .build())
                    
                    if status == .on {
                        do {
                            try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                            await self.refreshIpAddressesAsync()
                        }
                        catch {
                            self.publicIpRefreshingTask?.cancel()
                        }
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
                
                let shouldCheckConnection = self.appState.network.status == .on
                    && !self.appState.network.isObtainingIp
                
                guard shouldCheckConnection else {
                    continue
                }
                
                let builder = NetworkStateUpdateBuilder()
                
                do {
                    let hasInternetAccess = try await isUrlReachableAsync(url: self.appState.userData.internetCheckUrl)
                    
                    builder.withHasInternetAccess(hasInternetAccess)
                    
                    let reqiredIpRefresh = hasInternetAccess
                    && appState.userData.hasActiveIpApi()
                    && appState.network.publicIp == nil
                    
                    if reqiredIpRefresh {
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
        let shouldFetchPublicIp = !Task.isCancelled
            && appState.network.hasInternetAccess
            && appState.userData.ipApis.contains(where: { $0.isActive() })
        
        while shouldFetchPublicIp {
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
        guard !Task.isCancelled else { return }
        
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
        guard publicIp != nil && prevPublicIp != nil
              && publicIp?.ipAddress != prevPublicIp?.ipAddress else { return }
        
        executiveService.executeScript(publicIp: ip)
    }
}
