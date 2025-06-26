//
//  IpInfo.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import Foundation

struct IpInfo: Codable, Equatable {
    var ipAddress: String
    var countryCode: String
    var latitude: Double
    var longitude: Double
    var zipCode: String?
    var countryName: String?
    var regionName: String?
    var cityName: String?
    
    enum CodingKeys: String, CodingKey {
        case ipAddress
        case latitude
        case longitude
        case zipCode
        case countryCode
        case countryName
        case regionName
        case cityName
    }
    
    init(ipAddress: String){
        self.ipAddress = ipAddress
        self.latitude = 0.0
        self.longitude = 0.0
        self.zipCode = String()
        self.countryCode = String()
        self.countryName = String()
        self.regionName = String()
        self.cityName = String()
    }
    
    static func == (lhs: IpInfo, rhs: IpInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
            && lhs.countryCode == rhs.countryCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
    
    func asPhysicalAddressString() -> String {
        guard hasPhysicalLocation() else { return String() }
        
        var data = [String]()
        
        if let currentZipCode = zipCode, !currentZipCode.isEmpty {
            data.append(currentZipCode)
        }
        
        if let currentCountryName = countryName, !currentCountryName.isEmpty {
            data.append(currentCountryName)
        }
        
        if let currentRegionName = regionName, !currentRegionName.isEmpty {
            data.append(currentRegionName)
        }
        
        if let currentCityName = cityName, !currentCityName.isEmpty {
            data.append(currentCityName)
        }
        
        let result = data.enumerated().reduce(String()) { partialResult, pair in
            let (index, element) = pair
            let separator = index == 0 ? String() : ((index % 2 == 0) ? "\n" : ", ")
            return partialResult + separator + element
        }
        
        return result
    }
    
    func hasLocation() -> Bool {
        let emptyString = String()
        let emptyDouble = 0.0
        
        return countryCode != emptyString
        || latitude != emptyDouble
        || longitude != emptyDouble
    }
    
    func hasPhysicalLocation() -> Bool {
        return countryName != String()
    }
}
