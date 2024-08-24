//
//  NetworkInterface.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct NetworkInterface: Hashable, Equatable {
    let id: UUID
    let name: String
    let localizedName: String?
    var type: NetworkInterfaceType
    var isPhysical: Bool {
        get {
            let result = (type == .wired || type == .wifi || type == .cellular)
            return result
        }
    }
    
    init(name: String,
         type: NetworkInterfaceType,
         localizedName: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.localizedName = localizedName
    }
    
    static func == (lhs: NetworkInterface, rhs: NetworkInterface) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
    }
}
