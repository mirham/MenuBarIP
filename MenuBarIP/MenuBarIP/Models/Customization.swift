//
//  Customization.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct Customization: Codable, Identifiable, Equatable {
    var id = UUID()
    var type: CustomizableItemType
    var value: String
    var customText: String
    var customLightColor: String
    var customDarkColor: String
    var customTextLightColor: String
    var customTextDarkColor: String
    
    static func == (lhs: Customization, rhs: Customization) -> Bool {
        return  (lhs.id == rhs.id || lhs.value == rhs.value)
            && lhs.type == rhs.type
            && lhs.customText == rhs.customText
            && lhs.customLightColor == rhs.customLightColor
            && lhs.customDarkColor == rhs.customDarkColor
            && lhs.customTextLightColor == rhs.customTextLightColor
            && lhs.customTextDarkColor == rhs.customTextDarkColor
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(value)
    }
    
    func getIpInfoMatch(ipInfo: IpInfo) -> String? {
        let result: String?
        
        switch type {
            case .zip:
                result = ipInfo.zipCode
            case .country:
                result = ipInfo.countryName
            case .region:
                result = ipInfo.regionName
            case .city:
                result = ipInfo.cityName
            case .asn:
                result = ipInfo.asn
            case .isp:
                result = ipInfo.isp
            default:
                result = nil
        }
        
        guard let result = result
        else { return nil }
        
        guard !value.isEmpty
        else { return result }
        
        guard result.lowercased().contains(value.lowercased())
        else { return nil }
        
        return customText.isEmpty ? result : customText
    }
}
