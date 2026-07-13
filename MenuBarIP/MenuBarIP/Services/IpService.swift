//
//  IpService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import Factory
import Network

class IpService : ApiCallable, IpServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.ipApiService) private var ipApiService
    
    func getPublicIpAsync(ipApiUrl: String? = nil, withInfo: Bool = true) async -> OperationResult<IpInfo> {
        guard !Task.isCancelled
        else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        guard let apiUrl = ipApiUrl ?? ipApiService.getRandomActiveIpApi()?.url
        else {
            return OperationResult(error: Constants.errorNoActiveIpApiFound)
        }
        
        let ipAddress = try? await fetchIpAddressAsync(from: apiUrl)
        
        guard let ipAddress
        else {
            return OperationResult(error: Constants.errorIpApiResponseIsInvalid)
        }
        
        if withInfo {
            return await getPublicIpInfoAsync(
                apiUrl: appState.userData.ipInfoApiUrl,
                publicIp: ipAddress,
                keyMapping: appState.userData.ipInfoApiKeyMapping
            )
        }
        
        return OperationResult(result: IpInfo(ipAddress: ipAddress))
    }
    
    func getPublicIpInfoAsync(
        apiUrl: String,
        publicIp: String,
        keyMapping: [String:String]) async -> OperationResult<IpInfo> {
        guard !Task.isCancelled
        else { return OperationResult(error: Constants.errorTaskCancelled) }
        
        guard !keyMapping.isEmpty,
              let ipInfoUrl = ipApiService.prepareIpInfoApiUrl(
                publicIp: publicIp,
                ipInfoApiUrl: apiUrl)
        else { return OperationResult(result: IpInfo(ipAddress: publicIp)) }
        
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipInfoUrl,
                timeoutInterval: Constants.callTimeoutIpInfoApiInSeconds)
            
            guard let jsonData = response.data(using: .utf8)
            else { throw URLError(.cannotParseResponse) }
            
            let preparedJsonData = try jsonData.remap(mapping: keyMapping)
            let info = try JSONDecoder().decode(IpInfo.self, from: preparedJsonData)
            
            return OperationResult(result: info)
        } catch {
            if let urlError = error as? URLError,
               [.notConnectedToInternet, .networkConnectionLost].contains(urlError.code) {
                return OperationResult(result: IpInfo(ipAddress: publicIp))
            }
            
            let errorMessage = String(format: Constants.errorWhenCallingIpInfoApi, error.localizedDescription)
            return OperationResult(result: IpInfo(ipAddress: publicIp), error: errorMessage)
        }
    }
    
    func getLocalIp() -> String? {
        var result : String?

        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0
        else { return nil }
        
        guard let firstAddr = ifaddr
        else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                
                if name.hasPrefix(Constants.physicalNetworkInterfacePrefix) {
                    
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, 
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, 
                                socklen_t(hostname.count),
                                nil, 
                                socklen_t(0),
                                NI_NUMERICHOST)
                    result = String(cString: hostname)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        
        return result
    }
    
    func isLocalIp(ipString: String) -> Bool {
        if let ipv4 = IPv4Address(ipString) {
            if ipv4.isLoopback || ipv4.isLinkLocal { return true }
            
            let octets = ipString.split(separator: Constants.dot).compactMap { Int($0) }
           
            guard octets.count == 4
            else { return false }
            
            switch (octets[0], octets[1]) {
                case (10, _), (192, 168):
                    return true
                case (172, 16...31):
                    return true
                default:
                    break
            }
        }
        
        if let ipv6 = IPv6Address(ipString) {
            return ipv6.isLoopback || ipv6.isLinkLocal || ipv6.isUniqueLocal
        }
        
        return false
    }
    
    // MARK: Private functions
    
    private func fetchIpAddressAsync(from apiUrl: String) async throws -> String {
        let result = await ipApiService.callIpApiAsync(ipApiUrl: apiUrl)
        
        guard result.success,
              let ipAddress = result.result?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { throw result.error ?? Constants.errorIpApiResponseIsInvalid }
        
        guard ipAddress.isValidIp()
        else { throw Constants.errorIpApiResponseIsInvalid }
        
        return ipAddress
    }
}
