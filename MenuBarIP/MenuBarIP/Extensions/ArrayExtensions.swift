//
//  ArrayExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.12.2025.
//

extension Array where Element: Hashable {
    func syncWithDefaults(_ defaults: [Element], excluding excludedItems: [Element] = []) -> [Element] {
        let defaultSet = Set(defaults)
        let excludeSet = Set(excludedItems)
        
        var result: [Element] = []
        var seenItems = Set<Element>()
        
        for item in self where defaultSet.contains(item) && !excludeSet.contains(item) && !seenItems.contains(item) {
            result.append(item)
            seenItems.insert(item)
        }
        
        for (index, defaultItem) in defaults.enumerated() {
            if !excludeSet.contains(defaultItem) && !seenItems.contains(defaultItem) {
                let insertIndex = Swift.min(index, result.count)
                result.insert(defaultItem, at: insertIndex)
                seenItems.insert(defaultItem)
            }
        }
        
        return result
    }
}
