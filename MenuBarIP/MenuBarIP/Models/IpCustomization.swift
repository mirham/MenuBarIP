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
    var customTextLightColor: String
    var customTextDarkColor: String
    
    static func == (lhs: IpCustomization, rhs: IpCustomization) -> Bool {
        return  lhs.id == rhs.id || lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(ipAddress)
    }
}
