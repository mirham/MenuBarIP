//
//  LoggingServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation

protocol LoggingServiceType {
    func debug(_ message: String, _ destination: LogDestination)
    func info(_ message: String, _ destination: LogDestination)
    func error(_ message: String, _ destination: LogDestination)
    func getLogFileUrl() -> URL?
    func clearLogFile()
}

