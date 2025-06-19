//
//  IpService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import Factory

class IpService : ServiceBase, ApiCallable, IpServiceType {
    @Injected(\.ipApiService) private var ipApiService
    
    func getPublicIpAsync(ipApiUrl: String? = nil, withInfo: Bool = true) async -> OperationResult<IpInfo> {
        guard !Task.isCancelled else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        let currentIpApiUrl = ipApiUrl ?? ipApiService.getRandomActiveIpApi()?.url
        
        guard let currentIpApiUrl else {
            return OperationResult(error: Constants.errorNoActiveIpApiFound)
        }
        
        let ipAddressResult = await ipApiService.callIpApiAsync(ipApiUrl: currentIpApiUrl)
        guard ipAddressResult.success, let ipAddress = ipAddressResult.result?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return OperationResult(error: ipAddressResult.error ?? Constants.errorIpApiResponseIsInvalid)
        }
        
        guard ipAddress.isValidIp() else {
            return OperationResult(error: Constants.errorIpApiResponseIsInvalid)
        }
        
        if withInfo {
            let ipWithInfoResult = await getPublicIpInfoAsync(
                publicIp: ipAddress,
                keyMapping: appState.userData.ipInfoApiKeyMapping
            )
            
            return ipWithInfoResult
        }
        
        return OperationResult(result: IpInfo(ipAddress: ipAddress))
    }
    
    func getPublicIpInfoAsync(publicIp: String, keyMapping: [String:String]) async -> OperationResult<IpInfo> {
        guard !Task.isCancelled else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        guard !keyMapping.isEmpty,
              let ipInfoUrl = ipApiService.prepareIpInfoApiUrl(
                publicIp: publicIp,
                ipInfoApiUrl: appState.userData.ipInfoApiUrl
              ) else {
            return OperationResult(result: IpInfo(ipAddress: publicIp))
        }
        
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipInfoUrl,
                timeoutInterval: Constants.ipInfoApiCallTimeoutInSeconds)
            
            guard let jsonData = response.data(using: .utf8) else {
                throw URLError(.cannotParseResponse)
            }
            
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
        
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                
                if (name.hasPrefix(Constants.physicalNetworkInterfacePrefix)) {
                    
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
}
