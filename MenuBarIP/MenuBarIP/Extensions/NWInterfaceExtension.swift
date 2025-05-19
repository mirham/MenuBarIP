//
//  NWInterfaceExtension.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
import Network

extension NWInterface {
    internal func asNetworkInterface() -> NetworkInterface {
        switch self.type {
            case .cellular:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.cellular)
            case .loopback:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.loopback)
            case .wifi:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.wifi)
            case .wiredEthernet:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.wired)
            case .other:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.other)
            @unknown default:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.unknown)
        }
    }
}
