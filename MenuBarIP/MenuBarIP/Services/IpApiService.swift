//
//  IpApiService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 24.03.2025.
//

import Foundation
import Factory

class IpApiService : ApiCallable, IpApiServiceType {
    @Injected(\.appState) private var appState
    
    func getRandomActiveIpApi() -> IpApiInfo? {
        let result = self.appState.userData.ipApis.filter({$0.isActive()}).randomElement()
        
        return result
    }
    
    func prepareIpInfoApiUrl(publicIp: String, ipInfoApiUrl: String) -> String? {
        guard !ipInfoApiUrl.isEmpty
        else { return nil }
        
        guard !publicIp.isEmpty
        else { return nil }
        
        let result = ipInfoApiUrl.replacingOccurrences(
            of: Constants.publicIpMask,
            with: publicIp)
        
        guard result.isValidUrl()
        else { return nil }
        
        return result
    }
    
    func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String> {
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipApiUrl,
                timeoutInterval: calculateCallTimeout())
            
            return OperationResult(result: response)
        }
        catch {
            return await handleIpApiErrorAsync(error, for: ipApiUrl)
        }
    }
    
    // MARK: Private functions
    
    private func deactivateIpApiAsync(ipApiUrl: String) async {
        guard self.appState.network.status == .on
                && self.appState.network.hasInternetAccess
        else { return }
        
        if let inactiveApiIndex = self.appState.userData.ipApis
            .firstIndex(where: { $0.url == ipApiUrl }) {
            await MainActor.run() {
                self.appState.userData.ipApis[inactiveApiIndex].active = false
            }
        }
    }
    
    private func calculateCallTimeout() -> Double {
        let activeApisCount = self.appState.userData.ipApis.count(where: {$0.isActive()})
        
        guard activeApisCount > 0
        else { return Constants.callTimeoutIpApiInSeconds }
        
        let result = Constants.callTimeoutIpApiTotalInSeconds / Double(activeApisCount)
        
        return max(result, Constants.callTimeoutIpApiInSeconds)
    }
    
    private func handleIpApiErrorAsync(_ error: Error, for ipApiUrl: String) async -> OperationResult<String> {
        if let urlError = error as? URLError,
           [.notConnectedToInternet, .networkConnectionLost].contains(urlError.code) {
            return OperationResult(result: String())
        }
        
        await deactivateIpApiAsync(ipApiUrl: ipApiUrl)
        
        let errorMessage = String(
            format: Constants.errorWhenCallingIpAddressApi,
            ipApiUrl,
            error.localizedDescription
        )
        
        return OperationResult(error: errorMessage)
    }
}
