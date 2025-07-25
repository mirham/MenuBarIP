//
//  ExecutiveService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation
import Factory
import AppKit

class ExecutiveService: ServiceBase, ExecutiveServiceType {
    @Injected(\.loggingService) private var loggingService
    
    private let scriptPrefixLength = 2
    private let fileManager = FileManager.default
    private let scriptingQueue = DispatchQueue(label: Constants.scriptingQueueLabel, qos: .background)
    
    private let interpreterMap: [String: String] = [
        Constants.fileExtSh: Constants.pathZsh,
        Constants.fileExtPy: Constants.pathPython,
        Constants.fileExtRb: Constants.pathRuby,
        Constants.fileExtPl: Constants.pathPerl,
        Constants.fileExtPhp: Constants.pathPhp,
        Constants.fileExtScpt: Constants.pathAppleScript,
        Constants.fileExtJs: Constants.pathJs,
        Constants.fileExtDotNetScript: Constants.pathDotNetScript
    ]
    
    func execute(publicIp: String) {
        scriptingQueue.async {
            let scriptPath = self.appState.userData.scriptPath
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: scriptPath) else { return}
            guard fileManager.isReadableFile(atPath: scriptPath) else { return }
            
            let url = URL(fileURLWithPath: scriptPath)
            let pathExtension = url.pathExtension.lowercased()
            
            do {
                if pathExtension == Constants.fileExtApp {
                    try self.runApp(at: url, publicIp: publicIp)
                } else {
                    try self.runScript(at: url, publicIp: publicIp)
                }
            } catch {
                self.loggingService.error(
                    String(format: Constants.errorScriptCannotBeExecuted,
                           error.localizedDescription),
                    LogDestination.console)
            }
        }
    }
    
    func determineInterpreterPath (fileUrl: URL) throws -> URL {
        let pathExtension = fileUrl.pathExtension.lowercased()
        let interpreterCommand: String
        
        if let shebangInterpreterCommand = try parseShebang(from: fileUrl){
            interpreterCommand = shebangInterpreterCommand
        }
        else if let mappedInterpreter = interpreterMap[pathExtension] {
            interpreterCommand = mappedInterpreter
        }
        else if pathExtension == Constants.fileExtTxt {
            guard isScriptContent(url: fileUrl) else {
                throw String(format: Constants.errorScriptNotExecutable, fileUrl.path)
            }
            interpreterCommand = Constants.pathZsh
        }
        else {
            throw String(format: Constants.errorScriptTypeNotSupported, pathExtension)
        }
        
        guard let finalInterpreterPath = try resolveInterpreterCommandToPath(command: interpreterCommand)
        else { throw String(format: Constants.errorInterpreterNotFound, interpreterCommand) }
        
        let resultURL = URL(fileURLWithPath: finalInterpreterPath)
        
        guard fileManager.fileExists(atPath: resultURL.path)
        else { throw String(format: Constants.errorInterpreterNotFound, finalInterpreterPath) }
        
        guard fileManager.isExecutableFile(atPath: resultURL.path)
        else { throw String(format: Constants.errorInterpreterNotFound, finalInterpreterPath) }
        
        return resultURL
    }
    
    // MARK: Private functions
    
    private func isScriptContent(url: URL) -> Bool {
        guard let content = try? String(contentsOf: url, encoding: .utf8)
        else { return false }
        
        return content.hasPrefix(Constants.scriptContentPrefix)
    }
    
    private func parseShebang(from fileUrl: URL) throws -> String? {
        guard fileManager.isReadableFile(atPath: fileUrl.path)
        else { return nil }
        
        let content = try String(contentsOf: fileUrl, encoding: .utf8)
        let firstLine: String = content.prefix(
            while: { $0 != Constants.newLineChar })
            .trimmingCharacters(in: .whitespaces)
        
        guard firstLine.hasPrefix(Constants.scriptContentPrefix)
        else { return nil }
        
        let result = firstLine
            .dropFirst(scriptPrefixLength)
            .trimmingCharacters(in: .whitespaces)
        
        guard !result.isEmpty
        else { return nil }
        
        return result
    }
    
    func resolveInterpreterCommandToPath(command: String) throws -> String? {
        if command.hasPrefix(Constants.pathEnv) {
            let components = command
                .split(separator: Constants.space, maxSplits: 1)
                .map(String.init)
            
            guard components.count == scriptPrefixLength,
                  let actualCommand = components.last
            else { throw String(format: Constants.errorFailedToLocateInterpreter, command) }
            
            return try findExecutablePath(command: actualCommand)
        } else if command.hasPrefix(Constants.slash) {
            return command
        } else {
            return try findExecutablePath(command: command)
        }
    }
    
    private func runApp(at url: URL, publicIp: String) throws {
        Task {
            do {
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.arguments = [publicIp]
                
                try await NSWorkspace.shared.openApplication(
                    at: url,
                    configuration: configuration)
            } catch {
                throw String(format: Constants.errorAppCannotBeRan, error.localizedDescription)
            }
        }
    }
    
    private func runScript(at url: URL, publicIp: String) throws {
        var environment = ProcessInfo.processInfo.environment
        environment[Constants.envPathName] = Constants.envPossiblePathes
        let process = Process()
        process.environment = environment
        let interpreterUrl = try determineInterpreterPath(fileUrl: url)
        
        process.executableURL = interpreterUrl
        process.arguments = [url.path, publicIp]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            self.loggingService.error(
                String(format: Constants.errorScriptFailed, process.terminationStatus),
                LogDestination.console)
        }
    }
    
    private func findExecutablePath(command: String) throws -> String? {
        var environment = ProcessInfo.processInfo.environment
        environment[Constants.envPathName] = Constants.envPossiblePathes
        let process = Process()
        process.environment = environment
        process.launchPath = Constants.pathZsh
        process.arguments = ["-l", "-c", "command -v \(command)"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        if let output = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !output.isEmpty {
            return output
        }
        
        return nil
    }

}
