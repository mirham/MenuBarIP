//
//  IpCustomization.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct IpCustomization: Codable, Identifiable, Equatable {
    var id = UUID()
    var ipAddress: String
    var customText: String
    var customLightColor: String
    var customDarkColor: String
    
    static func == (lhs: IpCustomization, rhs: IpCustomization) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
