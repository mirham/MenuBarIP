//
//  IpApiService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 24.03.2025.
//

import Foundation

class IpApiService : ServiceBase, ApiCallable {
    static let shared = IpApiService()
    
    func getRandomActiveIpApi() -> IpApiInfo? {
        let result = self.appState.userData.ipApis.filter({$0.isActive()}).randomElement()
        
        return result
    }
    
    func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String> {
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
    
    func reactivateIpApis() {
        for ipApiIndex in self.appState.userData.ipApis.indices {
            if (!self.appState.userData.ipApis[ipApiIndex].isActive()) {
                DispatchQueue.main.async {
                    self.appState.userData.ipApis[ipApiIndex].active = true
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func deactivateIpApi(ipApiUrl: String) {
        guard self.appState.network.status == .on && self.appState.network.hasInternetAccess
        else { return }
        
        if let inactiveApiIndex = self.appState.userData.ipApis.firstIndex(where: { $0.url == ipApiUrl }) {
            DispatchQueue.main.async {
                self.appState.userData.ipApis[inactiveApiIndex].active = false
            }
        }
    }
}
