//
//  IpService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

class IpService : ServiceBase, ApiCallable {
    static let shared = IpService()
    
    func getPublicIpAsync(ipApiUrl: String? = nil, withInfo: Bool = true) async -> OperationResult<IpInfo> {
        var currentIpApiUrl = ipApiUrl
        
        if (currentIpApiUrl == nil) {
            let randomIpApi = getRandomActiveIpApi()
            currentIpApiUrl = randomIpApi?.url
        }
        
        guard currentIpApiUrl != nil else { return OperationResult(error: Constants.errorNoActiveIpApiFound) }
        let ipAddressResult = await callIpApiAsync(ipApiUrl: currentIpApiUrl!)
        guard ipAddressResult.success else { return OperationResult(error: ipAddressResult.error!) }
        let ipAddressString = ipAddressResult.result!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ipAddressString.isValidIp() else { return OperationResult(error: Constants.errorIpApiResponseIsInvalid) }
        
        if (withInfo) {
            let ipWithInfoResult = await getIpInfoAsync(ip: ipAddressString)
            
            return OperationResult(result: ipWithInfoResult.result! , error: ipWithInfoResult.error)
        }
        
        return OperationResult(result: IpInfo(ipAddress: ipAddressString))
    }
    
    func getIpInfoAsync(ip : String) async -> OperationResult<IpInfo> {
        do {
            // TODO RUSS: Add to Settings, add JSON mapping
            let response = try await callGetApiAsync(apiUrl: "https://freeipapi.com/api/json/\(ip)")
            let jsonData = response.data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let info = try decoder.decode(IpInfo.self, from: jsonData)
            
            return OperationResult(result: info)
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return OperationResult(result: IpInfo(ipAddress: ip))
            }
            
            if let error = error as? URLError, case .networkConnectionLost = error.code {
                return OperationResult(result: IpInfo(ipAddress: ip))
            }
            
            return OperationResult(
                result: IpInfo(ipAddress: ip),
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

    
    // MARK: Private functions
    
    private func getRandomActiveIpApi() -> IpApiInfo? {
        let result = self.appState.userData.ipApis.filter({$0.isActive()}).randomElement()
        
        return result
    }
    
    private func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String> {
        do {
            let response = try await callGetApiAsync(apiUrl: ipApiUrl)
            
            return OperationResult(result: response)
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return OperationResult(result: String())
            }
            
            if let error = error as? URLError, case .networkConnectionLost = error.code {
                return OperationResult(result: String())
            }
            
            deactivateIpApi(ipApiUrl: ipApiUrl)
            
            return OperationResult(error: String(format: Constants.errorWhenCallingIpAddressApi, ipApiUrl, error.localizedDescription))
        }
    }
    
    private func deactivateIpApi(ipApiUrl: String) {
        guard self.appState.network.status == .on && self.appState.network.internetAccess
            else { return }
        
        if let inactiveApiIndex = self.appState.userData.ipApis.firstIndex(where: { $0.url == ipApiUrl }) {
            DispatchQueue.main.async {
                self.appState.userData.ipApis[inactiveApiIndex].active = false
            }
        }
    }
}
