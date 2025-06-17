//
//  LoggingService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation
import os.log

class LoggingService: ServiceBase, LoggingServiceType {
    private let subsystem = Bundle.main.bundleIdentifier ?? Constants.defaultAppBundleName
    private let fileQueue = DispatchQueue(label: Constants.loggerQueueLabel, qos: .background)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.logEntryDateTimeMask
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private let loggers: [LogLevel: OSLog]
    
    override init() {
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
    
    func getLogFileUrl() -> URL? {
        guard let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
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
            guard let fileURL = self.getLogFileUrl() else {
                return
            }
            
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
        let logger = self.loggers[level] ?? .default
        let timestamp = self.dateFormatter.string(from: Date())
        let consoleMessage = "\(level.rawValue) \(message)"
        let fileMessage = "\(timestamp)  \(message)"
        
        if [LogDestination.console, LogDestination.both].contains(destination) {
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
            self.writeToLogFile(fileMessage)
        }
    }
    
    private func writeToLogFile(_ message: String) {
        fileQueue.async {
            guard let logFileUrl = self.getLogFileUrl() else {
                os_log(.error, log: .default, Constants.errorInvalidLogFileUrl)
                return
            }
            
            if !FileManager.default.fileExists(atPath: logFileUrl.path) {
                do {
                    try message.write(to: logFileUrl, atomically: true, encoding: .utf8)
                    
                    return
                } catch {
                    os_log(
                        .error,
                        log: .default,
                        Constants.errorFailedToCreateLogFile,
                        error.localizedDescription)
                    return
                }
            }
            
            do {
                let fileHandle = try FileHandle(forWritingTo: logFileUrl)
                
                defer { fileHandle.closeFile() }
                
                fileHandle.seekToEndOfFile()
                
                let logMessage = try self.isLogFileEmpty(fileUrl: logFileUrl)
                    ? message
                    : "\((Constants.newLine))\(message)"
                
                if let data = logMessage.data(using: .utf8) {
                    fileHandle.write(data)
                }
                
                self.trimLogFile(at: logFileUrl)
            } catch {
                os_log(
                    .error,
                    log: .default,
                    Constants.errorFailedToWriteLogFile,
                    error.localizedDescription)
            }
        }
    }
    
    private func trimLogFile(at fileURL: URL) {
        var recentLines: [String] = []
        
        do {
            guard let stream = InputStream(url: fileURL) else {
                os_log(.error, log: .default, Constants.errorFailedToCreateInputStreamForLogFile)
                return
            }
            
            stream.open()
            
            defer { stream.close() }
            
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }
            
            var partialLine = String()
            
            while stream.hasBytesAvailable {
                let bytesRead = stream.read(buffer, maxLength: bufferSize)
                
                if bytesRead < 0 {
                    throw stream.streamError ?? NSError(domain: Constants.loggerDomainName, code: -1, userInfo: nil)
                }
                
                if bytesRead == 0 { break }
                
                if let chunk = String(bytes: UnsafeBufferPointer(start: buffer, count: bytesRead), encoding: .utf8) {
                    let lines = (partialLine + chunk).split(
                        separator: Constants.newLine,
                        omittingEmptySubsequences: false)
                    partialLine = lines.last.map { String($0) } ?? String()
                    
                    for line in lines.dropLast(1) {
                        recentLines.append(String(line))
                        if recentLines.count > appState.userData.logFileLimit {
                            recentLines.removeFirst()
                        }
                    }
                }
            }
            
            if !partialLine.isEmpty {
                recentLines.append(partialLine)
                if recentLines.count > appState.userData.logFileLimit {
                    recentLines.removeFirst()
                }
            }
            
            if recentLines.count > appState.userData.logFileLimit {
                recentLines = Array(recentLines.suffix(appState.userData.logFileLimit))
            }
            
            let trimmedContent = recentLines.joined(separator: Constants.newLine)
            try trimmedContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            os_log(
                .error,
                log: .default,
                Constants.errorFailedToTrimLogFile,
                error.localizedDescription)
        }
    }
    
    private func isLogFileEmpty(fileUrl: URL) throws -> Bool {
        let fileManager = FileManager.default
        let attribtues = try fileManager.attributesOfItem(atPath: fileUrl.path)
        let fileSize = attribtues[.size] as? Int
        
        return fileSize == 0
    }
    
    // MARK: Inner types
    
    private enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case error = "ERROR"
    }
}
