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
    var asn: String?
    var isp: String?
    
    enum CodingKeys: String, CodingKey {
        case ipAddress
        case latitude
        case longitude
        case zipCode
        case countryCode
        case countryName
        case regionName
        case cityName
        case asn
        case isp
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
        self.asn = String()
        self.isp = String()
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
            let separator = index == 0
                ? String()
                : ((index % 2 == 0)
                   ? Constants.newLine
                   : Constants.commaSeparator)
            return partialResult + separator + element
        }
        
        return result
    }
    
    func hasLocation() -> Bool {
        let emptyDouble = 0.0
        
        return !countryCode.isEmpty
            || latitude != emptyDouble
            || longitude != emptyDouble
    }
    
    func hasPhysicalLocation() -> Bool {
        return countryName != String()
    }
    
    func hasIspInfo() -> Bool {
        guard asn != nil || isp != nil
        else { return false }
        
        guard !(asn?.isEmpty ?? true) || !(isp?.isEmpty ?? true)
        else { return false }
        
        return true
    }
    
    func asIspInfoString() -> String {
        guard hasIspInfo()
        else { return String() }
        
        var data = [String]()
        
        if let currentAsn = asn, !currentAsn.isEmpty {
            data.append(currentAsn)
        }
        
        if let currentIsp = isp, !currentIsp.isEmpty {
            if data.count > 0 {
                data.append(" \(Constants.hyphen) ")
            }
            data.append(currentIsp)
        }
        
        var result = data.joined().description
        
        if result.count > Constants.maxMenuLineLength {
            data = splitIntoLines(result, lines: data)
            
            result = data.joined(separator: Constants.newLine)
        }
        
        return result
    }
    
    // MARK: Private functions
    
    private func splitIntoLines(_ string: String, lines: [String]) -> [String] {
        let words = string.split(separator: Constants.space).map { String($0) }
        var currentLine = String()
        var result = [String]()
        
        for word in words {
            if currentLine.isEmpty {
                if word.count <=  Constants.maxMenuLineLength {
                    currentLine = word
                } else {
                    var remaining = word
                    
                    while !remaining.isEmpty {
                        let takeCount = min(Constants.maxMenuLineLength, remaining.count)
                        result.append(String(remaining.prefix(takeCount)))
                        remaining = String(remaining.dropFirst(takeCount))
                    }
                }
            } else if (currentLine.count + 1 + word.count) <= Constants.maxMenuLineLength {
                currentLine += " \(word)"
            } else {
                result.append(currentLine)
                if word.count <= Constants.maxMenuLineLength {
                    currentLine = word
                } else {
                    var remaining = word
                    while !remaining.isEmpty {
                        let takeCount = min(Constants.maxMenuLineLength, remaining.count)
                        result.append(String(remaining.prefix(takeCount)))
                        remaining = String(remaining.dropFirst(takeCount))
                    }
                    currentLine = String()
                }
            }
        }
        
        if !currentLine.isEmpty {
            result.append(currentLine)
        }
        
        return result
    }
}
