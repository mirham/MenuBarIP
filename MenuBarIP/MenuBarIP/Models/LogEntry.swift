//
//  LogEntry.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    let message: String
}
