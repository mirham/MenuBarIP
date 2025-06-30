//
//  DictionaryExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 30.06.2025.
//

import Foundation

extension Dictionary {
    func mergingMissingPairs(from other: [Key: Value]) -> [Key: Value] {
        var result = self
        result.merge(other) { (current, _) in current }
        return result
    }
}
