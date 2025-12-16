//
//  IpServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

protocol IpServiceType {
    func getPublicIpAsync(ipApiUrl: String?, withInfo: Bool) async -> OperationResult<IpInfo>
    func getPublicIpInfoAsync(
        apiUrl: String,
        publicIp: String,
        keyMapping: [String:String]) async -> OperationResult<IpInfo>
    func getLocalIp() -> String?
    func isLocalIp(ipString: String) -> Bool
}
