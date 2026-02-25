//
//  NetworkServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

protocol NetworkServiceType {
    func isUrlReachableAsync(url : String) async throws -> Bool
    func refreshIpAddressesAsync(isManually: Bool) async
    func refreshIpAddressesManuallyAsync() async
}
