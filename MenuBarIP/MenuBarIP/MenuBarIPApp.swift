//
//  MenuBarIPApp.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

@main
struct MenuBarIPApp: App {
    let appState = AppState.shared
    
    init() {
        _ = NetworkStatusService()
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
                .environmentObject(appState)
        } label: {
            HStack {
                MenuBarStatusView()
                    .environmentObject(appState)
            }
        }
        .menuBarExtraStyle(.menu)
        
        WindowGroup(id:Constants.windowIdSettings, content: {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.settings)
                .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
        
        WindowGroup(id:Constants.windowIdPublicIpLocation, content: {
            PublicIpLocationView()
                .environmentObject(appState)
                .navigationTitle(Constants.location)
                .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
    }
}
