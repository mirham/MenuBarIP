//
//  ExecutiveService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation
import Factory

class ExecutiveService: ServiceBase, ExecutiveServiceType {
    @Injected(\.loggingService) private var loggingService
    
    private let scriptingQueue = DispatchQueue(label: Constants.scriptingQueueLabel, qos: .background)
    
    func executeScript(publicIp: String) {
        scriptingQueue.async {
            let scriptPath = self.appState.userData.scriptPath
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: scriptPath) else { return}
            guard fileManager.isExecutableFile(atPath: scriptPath) else { return }
            
            let process = Process()
            process.launchPath = Constants.zshPath
            process.arguments = [scriptPath, publicIp]
            
            do {
                try process.run()
                process.waitUntilExit()
                
                if process.terminationStatus != 0 {
                    self.loggingService.error(String(format: Constants.errorScriptFailed, process.terminationStatus), LogDestination.console)
                }
            } catch {
                self.loggingService.error(String(format: Constants.errorScriptCannotBeExecuted, error.localizedDescription), LogDestination.console)
            }
        }
    }
}
