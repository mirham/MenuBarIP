//
//  IpInfo.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import Foundation
import Network

struct IpInfo: Codable, Equatable {
    var ipVersion: Int
    var ipAddress: String
    var latitude: Double
    var longitude: Double
    var zipCode: String
    var countryCode: String
    var countryName: String
    var regionName: String
    var cityName: String
    
    static func == (lhs: IpInfo, rhs: IpInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    init(ipAddress: String){
        self.ipVersion = (IPv4Address(ipAddress) != nil) ? Constants.ipV4 : Constants.ipV6
        self.ipAddress = ipAddress
        self.latitude = 0.0
        self.longitude = 0.0
        self.zipCode = String()
        self.countryCode = String()
        self.countryName = String()
        self.regionName = String()
        self.cityName = String()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
