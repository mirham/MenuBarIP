//
//  NetworkStateUpdateBuilder.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 23.05.2025.
//

final class NetworkStateUpdateBuilder {
    private var update = NetworkStateUpdate()
    
    @discardableResult
    func withStatus(_ status: NetworkStatusType) -> Self {
        update.status = status
        
        return self
    }
    
    @discardableResult
    func withPublicIp(_ publicIp: IpInfo?) -> Self {
        update.publicIp = publicIp
        update.forceUpdatePublicIp = true
        
        return self
    }
    
    @discardableResult
    func withLocalIp(_ localIp: String?) -> Self {
        update.localIp = localIp
        return self
    }
    
    @discardableResult
    func withActiveNetworkInterfaces(_ interfaces: [NetworkInterface]) -> Self {
        update.activeNetworkInterfaces = interfaces
        return self
    }
    
    @discardableResult
    func withIsDisconnected(_ isDisconnected: Bool) -> Self {
        update.isDisconnected = isDisconnected
        
        if isDisconnected {
            update.publicIp = nil
            update.forceUpdatePublicIp = true
        }
        
        return self
    }
    
    @discardableResult
    func withIsObtainingIp(_ isObtainingIp: Bool) -> Self {
        update.isObtainingIp = isObtainingIp
        return self
    }
    
    @discardableResult
    func withHasInternetAccess(_ hasInternetAccess: Bool) -> Self {
        update.hasInternetAccess = hasInternetAccess
        return self
    }
    
    func build() -> NetworkStateUpdate {
        update
    }
}
