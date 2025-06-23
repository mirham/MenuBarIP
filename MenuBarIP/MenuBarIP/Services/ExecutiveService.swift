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
    
    private let fileManager = FileManager.default
    private let scriptingQueue = DispatchQueue(label: Constants.scriptingQueueLabel, qos: .background)
    
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
                self.loggingService.error(String(format: Constants.errorScriptCannotBeExecuted, error.localizedDescription), LogDestination.console)
            }
        }
    }
    
    func determineInterpreterPath (fileUrl: URL) throws -> URL {
        let pathExtension = fileUrl.pathExtension.lowercased()
        var interpreter: String
        
        switch pathExtension {
            case Constants.fileExtSh:
                interpreter = Constants.pathZsh
            case Constants.fileExtPy:
                interpreter = Constants.pathPython
            case Constants.fileExtRb:
                interpreter = Constants.pathRuby
            case Constants.fileExtPl:
                interpreter = Constants.pathPerl
            case Constants.fileExtPhp:
                interpreter = Constants.pathPhp
            case Constants.fileExtScpt:
                interpreter = Constants.pathAppleScript
            case Constants.fileExtJs:
                interpreter = Constants.pathJs
            case Constants.fileExtTxt:
                guard isScriptContent(url: fileUrl) else {
                    throw String(format: Constants.errorScriptNotExecutable, fileUrl.path)
                }
                interpreter = Constants.pathZsh
            default:
                throw String(format: Constants.errorScriptTypeNotSupported, pathExtension)
        }
        
        let result = URL(fileURLWithPath: interpreter)
        
        guard fileManager.fileExists(atPath: result.path) else {
            throw String(format: Constants.errorInterpreterNotFound, interpreter)
        }
        
        return result
    }
    
    // MARK: Private functions
    
    private func isScriptContent(url: URL) -> Bool {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return false
        }
        return content.hasPrefix("#!")
    }
    
    private func runApp(at url: URL, publicIp: String) throws {
        Task {
            do {
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.arguments = [publicIp]
                
                try await NSWorkspace.shared.openApplication(at: url, configuration: configuration)
            } catch {
                throw String(format: Constants.errorAppCannotBeRan, error.localizedDescription)
            }
        }
    }
    
    private func runScript(at url: URL, publicIp: String) throws {
        let process = Process()
        let interpreterUrl = try determineInterpreterPath(fileUrl: url)
        
        process.executableURL = interpreterUrl
        process.arguments = [url.path, publicIp]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            self.loggingService.error(String(format: Constants.errorScriptFailed, process.terminationStatus), LogDestination.console)
        }
    }
}
