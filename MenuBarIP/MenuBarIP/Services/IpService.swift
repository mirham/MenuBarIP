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
        var currentIpApiUrl = ipApiUrl
        
        if (currentIpApiUrl == nil) {
            let randomIpApi = ipApiService.getRandomActiveIpApi()
            currentIpApiUrl = randomIpApi?.url
        }
        
        guard currentIpApiUrl != nil else { return OperationResult(error: Constants.errorNoActiveIpApiFound) }
        let ipAddressResult = await ipApiService.callIpApiAsync(ipApiUrl: currentIpApiUrl!)
        guard ipAddressResult.success else { return OperationResult(error: ipAddressResult.error!) }
        let ipAddressString = ipAddressResult.result!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ipAddressString.isValidIp() else { return OperationResult(error: Constants.errorIpApiResponseIsInvalid) }
        
        if withInfo {
            let ipWithInfoResult = await getPublicIpInfoAsync(
                publicIp: ipAddressString,
                keyMapping: appState.userData.ipInfoApiKeyMapping)
            
            return OperationResult(result: ipWithInfoResult.result! , error: ipWithInfoResult.error)
        }
        
        return OperationResult(result: IpInfo(ipAddress: ipAddressString))
    }
    
    func getPublicIpInfoAsync(publicIp: String, keyMapping: [String:String]) async -> OperationResult<IpInfo> {
        guard let ipInfoUrl = ipApiService.prepareIpInfoApiUrl(
            publicIp: publicIp,
            ipInfoApiUrl: appState.userData.ipInfoApiUrl),
            !keyMapping.isEmpty
        else {
            return OperationResult(result: IpInfo(ipAddress: publicIp))
        }
        
        do {
            let response = try await callGetApiAsync(apiUrl: ipInfoUrl)
            let jsonData = response.data(using: .utf8)!
            let preparedJsonData = try jsonData.remap(mapping: keyMapping)
            let decoder = JSONDecoder()
            let info = try decoder.decode(IpInfo.self, from: preparedJsonData)
            
            return OperationResult(result: info)
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return OperationResult(result: IpInfo(ipAddress: publicIp))
            }
            
            if let error = error as? URLError, case .networkConnectionLost = error.code {
                return OperationResult(result: IpInfo(ipAddress: publicIp))
            }
            
            return OperationResult(
                result: IpInfo(ipAddress: publicIp),
                error: String(format: Constants.errorWhenCallingIpInfoApi, error.localizedDescription))
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
