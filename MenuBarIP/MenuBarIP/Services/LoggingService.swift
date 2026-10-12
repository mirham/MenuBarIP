//
//  LoggingService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation
import Factory
import os.log

final class LoggingService: LoggingServiceType {
    @Injected(\.appState) private var appState
    
    private let subsystem = Bundle.main.bundleIdentifier ?? Constants.defaultAppBundleName
    private let fileQueue = DispatchQueue(label: Constants.loggerQueueLabel, qos: .background)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.logEntryDateTimeMask
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private let loggers: [LogLevel: OSLog]
    
    init() {
        loggers = [
            .debug: OSLog(
                subsystem: subsystem,
                category: LogLevel.debug.rawValue.firstLetterUppercased),
            .info: OSLog(
                subsystem: subsystem,
                category: LogLevel.info.rawValue.firstLetterUppercased),
            .error: OSLog(
                subsystem: subsystem,
                category: LogLevel.error.rawValue.firstLetterUppercased)
        ]
    }
    
    func debug(_ message: String, _ destination: LogDestination) {
        log(message, level: .debug, destination: destination)
    }
    
    func info(_ message: String, _ destination: LogDestination) {
        log(message, level: .info, destination: destination)
    }
    
    func error(_ message: String, _ destination: LogDestination) {
        log(message, level: .error, destination: destination)
    }
    
    nonisolated func getLogFileUrl() -> URL? {
        guard let appSupportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            os_log(.error, log: .default, Constants.errorFailedToCreateAppSupportFolder)
            return nil
        }
        
        let appDirectory = appSupportDirectory.appendingPathComponent(subsystem)
        
        do {
            try FileManager.default.createDirectory(
                at: appDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            os_log(
                .error,
                log: .default,
                Constants.errorFailedToCreateAppFolder, error.localizedDescription)
            return nil
        }
        
        return appDirectory.appendingPathComponent(Constants.logFileName)
    }
    
    func clearLogFile() {
        fileQueue.async {
            guard let fileURL = self.getLogFileUrl()
            else { return }
            
            do {
                try String().write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                os_log(
                    .error,
                    log: .default,
                    Constants.errorFailedToClearLogFile,
                    error.localizedDescription)
            }
        }
    }
    
    // MARK: Private functions
    
    private func log(_ message: String, level: LogLevel, destination: LogDestination) {
        if [LogDestination.console, LogDestination.both].contains(destination) {
            let logger = loggers[level] ?? .default
            let consoleMessage = "\(level.rawValue) \(message)"
            
            switch level {
                case .debug:
                    os_log(.debug, log: logger, Constants.logConsoleMessageMask, consoleMessage)
                case .info:
                    os_log(.info, log: logger, Constants.logConsoleMessageMask, consoleMessage)
                case .error:
                    os_log(.error, log: logger, Constants.logConsoleMessageMask, consoleMessage)
            }
        }
        
        if [LogDestination.file, LogDestination.both].contains(destination) {
            let timestamp = dateFormatter.string(from: Date())
            
            writeToLogFile("\(timestamp)  \(message)")
        }
    }
    
    private func writeToLogFile(_ message: String) {
        let limit = appState.userData.logFileLimit
        
        fileQueue.async {
            guard let logFileUrl = self.getLogFileUrl() else {
                os_log(.error, log: .default, Constants.errorInvalidLogFileUrl)
                return
            }
            
            do {
                try Self.append(message, to: logFileUrl, limit: limit)
            } catch {
                os_log(
                    .error,
                    log: .default,
                    Constants.errorFailedToWriteLogFile,
                    error.localizedDescription)
            }
        }
    }
    
    private nonisolated static func append(
        _ message: String,
        to url: URL,
        limit: Int) throws {
            let existing = (try? String(contentsOf: url, encoding: .utf8)) ?? String()
            
            var lines = existing.isEmpty
            ? [String]()
            : existing
                .split(separator: Constants.newLine, omittingEmptySubsequences: false)
                .map(String.init)
            
            lines.append(message)
            
            if lines.count > limit {
                lines.removeFirst(lines.count - limit)
            }
            
            try lines
                .joined(separator: Constants.newLine)
                .write(to: url, atomically: true, encoding: .utf8)
        }
    
    // MARK: Inner types
    
    private enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case error = "ERROR"
    }
}
