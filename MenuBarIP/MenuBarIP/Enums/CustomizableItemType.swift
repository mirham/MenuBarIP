//
//  CustomizableItemType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 25.02.2026.
//

import Foundation

enum CustomizableItemType : Int, CaseIterable, Codable {
    case unknown = 0
    case ip = 1
    case zip = 2
    case country = 3
    case region = 4
    case city = 5
    case asn = 6
    case isp = 7
    
    var displayName: String {
        switch self {
            case .unknown: return "Unknown"
            case .ip: return "IP"
            case .zip: return "ZIP"
            case .country: return "Country"
            case .region: return "Region"
            case .city: return "City"
            case .asn: return "ASN"
            case .isp: return "ISP"
        }
    }
    
    static var pickerCases: [CustomizableItemType] {
        Self.allCases.filter { $0.rawValue > 1 }
    }
}
