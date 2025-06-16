//
//  NetworkStateUpdate.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 23.05.2025.
//

struct NetworkStateUpdate {
    var status: NetworkStatusType?
    var prevPublicIp: IpInfo?
    var publicIp: IpInfo?
    var localIp: String?
    var activeNetworkInterfaces: [NetworkInterface]?
    var isDisconnected: Bool?
    var isObtainingIp: Bool?
    var hasInternetAccess: Bool?
    var forceUpdatePublicIp: Bool = false
}
