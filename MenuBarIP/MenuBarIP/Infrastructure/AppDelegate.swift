//
//  AppDelegate.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 15.10.2026.
//


import AppKit
import Factory

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Container.shared.launchAgentService().removeLegacyAgent()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        let service = Container.shared.launchAgentService()
        
        if service.hasPendingChange {
            service.apply()
        }
    }
}
