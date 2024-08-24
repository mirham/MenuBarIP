//
//  OperationResult.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

class OperationResult<T> {
    let result: T?
    let success: Bool
    let error: String?
    
    init(result: T) {
        self.result = result
        self.success = true
        self.error = nil
    }
    
    init(error: String) {
        self.result = nil
        self.success = false
        self.error = error
    }
    
    init(result: T, error: String?) {
        self.result = result
        self.success = true
        self.error = error
    }
}
