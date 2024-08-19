//
//  IpInfoBase.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import Foundation
import Network

struct IpInfoBase: Codable, Equatable {
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode: String
    
    static func == (lhs: IpInfoBase, rhs: IpInfoBase) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    init(ipAddress: String){
        self.ipVersion = (IPv4Address(ipAddress) != nil) ? Constants.ipV4 : Constants.ipV6
        self.ipAddress = ipAddress
        self.countryName = String()
        self.countryCode = String()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
