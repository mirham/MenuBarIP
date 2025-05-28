//
//  NetworkServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

protocol NetworkServiceType {
    func refreshIpAddressesAsync() async
    func isUrlReachableAsync(url : String) async throws -> Bool
}
