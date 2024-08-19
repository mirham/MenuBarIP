//
//  IpApiInfo.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct IpApiInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var url: String
    
    @CodableIgnored
    var active: Bool?
    
    func isActive() -> Bool {
        return active ?? true
    }
    
    static func == (lhs: IpApiInfo, rhs: IpApiInfo) -> Bool {
        return lhs.url.uppercased() == rhs.url.uppercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
