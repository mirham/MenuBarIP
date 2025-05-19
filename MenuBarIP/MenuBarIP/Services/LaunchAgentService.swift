//
//  LaunchAgentService.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

class LaunchAgentService : ServiceBase, ShellAccessible, LaunchAgentServiceType {
    var isInstalled: Bool = false
    
    override init() {
        super.init()
        
        let fileManager = FileManager.default
        let plistFilePath = getPlistFilePath()
        
        if(fileManager.fileExists(atPath: plistFilePath)) {
            isInstalled = true
        }
    }
    
    func create() -> Bool {
        let appPath = Bundle.main.executablePath
        let plistFilePath = getPlistFilePath()
        let xmlContent = String(format: Constants.launchAgentXmlContent, appPath!)
        
        do {
            try xmlContent.write(toFile: plistFilePath, atomically: true, encoding: String.Encoding.utf8)
            
            return true
        }
        catch {
            return false
        }
    }
    
    func setState(isInstalled: Bool) {
        self.isInstalled = isInstalled
    }
    
    func apply() {
        do {
            if(self.isInstalled){
                try safeShell(String(format: Constants.shCommandLoadLaunchAgent, Constants.launchAgentsFolderPath, Constants.launchAgentPlistName))
            }
            else{
                try safeShell(String(format: Constants.shCommandRemoveLaunchAgent, Constants.launchAgentName))
            }
        }
        catch {}
    }
    
    func delete() -> Bool {
        do {
            let fileManager = FileManager.default
            let plistFilePath = getPlistFilePath()
            try fileManager.removeItem(atPath: plistFilePath)
            
            return true
        }
        catch {
            return false
        }
    }
    
    // MARK: Private functions
    
    private func getPlistFilePath() -> String {
        let userDirectory = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor:.libraryDirectory,
            create: false)
        let launchAgentsFolder = userDirectory
            .appendingPathComponent(Constants.launchAgents)
            .appendingPathComponent(Constants.launchAgentPlistName)
        let filename = URL(fileURLWithPath: launchAgentsFolder.path(), isDirectory: false)
        let result = filename.path()
        
        return result
    }
}
