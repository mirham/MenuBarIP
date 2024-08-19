//
//  IpInfo.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct IpInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode: String
    var customText: String
    var customColor: String
    
    init(ipAddress: String,
         ipAddressInfo: IpInfoBase?,
         customText: String = String(),
         customColor: String = String()) {
        let info = ipAddressInfo ?? IpInfoBase(ipAddress: ipAddress)
        
        self.ipVersion = info.ipVersion
        self.ipAddress = info.ipAddress
        self.countryName = info.countryName
        self.countryCode = info.countryCode
        self.customText = customText
        self.customColor = customColor
    }
    
    static func == (lhs: IpInfo, rhs: IpInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
