//
//  NetworkService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import Network
import SystemConfiguration
import AppKit
import Factory

class NetworkService: ApiCallable, NetworkServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.ipService) private var ipService
    @Injected(\.ipApiService) private var ipApiService
    @Injected(\.executiveService) private var executiveService
    @Injected(\.loggingService) private var loggingSerevice
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    private var ipUpdateTask: Task<Void, Never>?
    private var monitoringTask: Task<Void, Never>?
    private var periodicCheckIpTask: Task<Void, Never>?
    
    init() {
        startNetworkMonitoring()
        startConnectionHealthMonitoring()
        startPeriodicIpCheck()
        addSystemDidWakeHandler()
    }
    
    deinit {
        monitor.cancel()
        monitoringTask?.cancel()
        ipUpdateTask?.cancel()
        periodicCheckIpTask?.cancel()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    func isUrlReachableAsync(url : String) async throws -> Bool {
        guard !Task.isCancelled
        else { throw CancellationError() }
        
        guard let url = URL(string: url)
        else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = Constants.headHttpMethod
        request.timeoutInterval = Constants.callTimeoutSiteInSeconds
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse
                else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    
                    return
                }
                
                continuation.resume(returning: httpResponse.statusCode == 200)
            }
            
            task.resume()
        }
    }
    
    func refreshIpAddressesAsync(isManually: Bool = false) async {
        guard !Task.isCancelled
        else { return }
        
        let prevPublicIp = appState.network.publicIp
        var loadingTask: Task<Void, Never>?
        
        func showObtainingStatus() async {
            await updateStatusAsync(update: NetworkStateUpdateBuilder()
                .withIsObtainingIp(true)
                .build())
        }
        
        if (isManually) {
            await showObtainingStatus()
        }
        else {
            loadingTask = Task {
                try? await Task.sleep(nanoseconds: Constants.secondInNanoseconds)
                
                guard !Task.isCancelled else { return }
                
                await showObtainingStatus()
            }
        }
        
        let localIp = ipService.getLocalIp()
        let publicIp = await fetchPublicIpAsync()
        
        loadingTask?.cancel()
        
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(false)
            .withPublicIp(publicIp)
            .withLocalIp(localIp)
            .build())
        
        guard !Task.isCancelled else { return }
        
        writeLog(publicIp: publicIp)
        executeScript(prevPublicIp: prevPublicIp, publicIp: publicIp)
    }
    
    func refreshIpAddressesManuallyAsync() async {
        guard !Task.isCancelled
        else { return }
        
        let builder = NetworkStateUpdateBuilder()
        let hasInternetAccess = await checkIfInternetConnectionAsync()
        
        builder.withHasInternetAccess(hasInternetAccess)
        
        if hasInternetAccess {
            await reactivateIpApisAsync()
            await refreshIpAddressesAsync(isManually: true)
            await refreshIpInfoIfNeededAsync()
        } else {
            builder.withHasInternetAccess(false)
                .withPublicIp(nil)
        }
        
        await updateStatusAsync(update: builder.build())
    }
    
    // MARK: Private functions
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self
            else { return }
            
            let networkInterfaces = self.determineNetworkInterfaces(path: path)
            let status = self.determineNetworkStatusType(path: path, networkInterfaces: networkInterfaces)
            let isConnectionChanged = self.appState.network.isConnectionChanged (
                status: status,
                activeNetworkInterfaces: networkInterfaces)
            
            guard isConnectionChanged
            else { return }
            
            let updatedStatus = status
            let updatedNetworkInterfaces = networkInterfaces
            
            self.ipUpdateTask?.cancel()
            
            self.ipUpdateTask = Task {
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
                        self.ipUpdateTask?.cancel()
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
                
                guard await shouldCheckConnectionWithRetryAsync()
                else { continue }
                
                await performConnectionHealthCheckAsync()
            }
        }
    }
    
    func startPeriodicIpCheck() {
        let builder = NetworkStateUpdateBuilder()
        
        periodicCheckIpTask = Task {
            while !Task.isCancelled {
                guard self.appState.userData.periodicIpCheck else {
                    try? await Task.sleep(nanoseconds:UInt64(Constants.minTimeIntervalToCheck) * Constants.secondInNanoseconds)
                    continue
                }
                
                try? await Task.sleep(nanoseconds:UInt64(self.appState.userData.intervalBetweenChecks) * Constants.secondInNanoseconds)
                
                let publicIp = await fetchPublicIpAsync()
                
                await updateStatusAsync(update: builder
                    .withPublicIp(publicIp)
                    .build())
                
                writeLog(publicIp: publicIp)
            }
        }
    }
    
    private func shouldCheckConnection() -> Bool {
        return appState.network.status != .off
                && !appState.network.isObtainingIp
    }
    
    private func shouldCheckConnectionWithRetryAsync() async -> Bool {
        for _ in 0..<Constants.minMaxConnectionChecks {
            if shouldCheckConnection() {
                return true
            }
            
            try? await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
        }
        
        return shouldCheckConnection()
    }
    
    private func performConnectionHealthCheckAsync() async {
        let builder = NetworkStateUpdateBuilder()
        
        var hasInternetAccess = await checkIfInternetConnectionAsync()
        
        if !hasInternetAccess {
            let startTime = Date()
            
            while Date().timeIntervalSince(startTime) < Constants.callTimeoutIpApiInSeconds {
                hasInternetAccess = await checkIfInternetConnectionAsync()
                
                if hasInternetAccess {
                    break
                }
                
                try? await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
            }
        }
        
        builder.withHasInternetAccess(hasInternetAccess)
        
        if hasInternetAccess {
            await refreshIpAddressIfNeededAsync()
            await refreshIpInfoIfNeededAsync()
        } else {
            builder.withHasInternetAccess(false)
                .withPublicIp(nil)
        }
        
        await updateStatusAsync(update: builder.build())
    }
    
    private func reactivateIpApisAsync() async {
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            appState.userData.reactivateIpApis()
        }
    }
    
    private func refreshIpAddressIfNeededAsync() async {
        let requiresIpRefresh = appState.userData.hasActiveIpApi()
            && appState.network.publicIp == nil
        
        if requiresIpRefresh {
            await refreshIpAddressesAsync()
        }
    }
    
    private func refreshIpInfoIfNeededAsync() async {
        guard let publicIp = appState.network.publicIp, !publicIp.hasLocation()
        else { return }
        
        await refreshPublicIpInfoAsync()
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
    
    private func getNetworkInterfaceTypeByInterfaceName(interfaceName: String) -> NetworkInterfaceType {
        if interfaceName.range(
            of: Constants.physicalNetworkInterfaceWiFi,
            options: .caseInsensitive) != nil {
            return NetworkInterfaceType.wifi
        }
        
        if interfaceName.range(
            of: Constants.physicalNetworkInterfaceLan,
            options: .caseInsensitive) != nil {
            return NetworkInterfaceType.wired
        }
        
        return NetworkInterfaceType.other
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
    
    func refreshPublicIpInfoAsync() async {
        guard !Task.isCancelled else { return }
        
        guard let publicIpAddress = appState.network.publicIp?.ipAddress
        else { return }
        
        let publicIpInfoResult = await ipService.getPublicIpInfoAsync(
            apiUrl: appState.userData.ipInfoApiUrl,
            publicIp: publicIpAddress,
            keyMapping: appState.userData.ipInfoApiKeyMapping)
        
        guard publicIpInfoResult.success else { return }
        
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withPublicIp(publicIpInfoResult.result)
            .build())
    }
    
    private func checkIfInternetConnectionAsync() async -> Bool {
        await withTaskGroup(of: Bool?.self) { group in
            let urls = [
                appState.userData.internetCheckUrl1,
                appState.userData.internetCheckUrl2,
                appState.userData.internetCheckUrl3
            ]
            
            for url in urls {
                group.addTask {
                    try? await self.isUrlReachableAsync(url: url)
                }
            }
            
            for await result in group {
                if result == true {
                    group.cancelAll()
                    return true
                }
            }
            
            return false
        }
    }
    
    @objc private func systemDidWake() {
        if appState.network.publicIp == nil {
            Task {
                await refreshIpAddressesAsync()
            }
        }
    }
    
    private func updateStatusAsync(update: NetworkStateUpdate) async {
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
            appState.network.refreshSignal.toggle()
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
        
        executiveService.execute(publicIp: ip)
    }
}
