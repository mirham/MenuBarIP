//
//  DataExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 17.06.2025.
//

import Foundation

extension Data {
    func remap(mapping: [String: String]) throws -> Data {
        guard let json = try JSONSerialization
            .jsonObject(with: self) as? [String: Any] else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: Constants.errorInvalidJson))
        }
        
        var remapped: [String: Any] = [:]
        
        for mapppingPair in mapping {
            if let key = json.keys.first(where: {$0 == mapppingPair.value}) {
                remapped[mapppingPair.key] = json[key]
            }
            else {
                remapped[mapppingPair.key] = nil
            }
        }
        
        return try JSONSerialization.data(withJSONObject: remapped)
    }
}
