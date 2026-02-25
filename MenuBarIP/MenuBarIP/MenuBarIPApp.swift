//
//  MenuBarIPApp.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI
import Factory

@main
struct MenuBarIPApp: App {
    let appState = AppState.shared
    
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
        
        WindowGroup(id:Constants.windowIdSettings, makeContent: {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.menuItemSettings)
                .safeGlassEffect()
                .frame(minWidth: 680, maxWidth: 680, minHeight: 550, maxHeight: 550)
        })
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        WindowGroup(id:Constants.windowIdPublicIpLocation, makeContent: {
            PublicIpLocationView()
                .environmentObject(appState)
                .navigationTitle(Constants.wnidowTitlePublicIplocation)
                .frame(minWidth: 500, minHeight: 500)
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id:Constants.windowIdLog, makeContent: {
            LogView(container: Container())
                .environmentObject(appState)
                .navigationTitle(Constants.wnidowTitlePublicIpLog)
                .safeGlassEffect()
                .frame(minWidth: 400, minHeight: 400)
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdInfo, makeContent: {
            InfoView()
                .environmentObject(appState)
                .navigationTitle(Constants.info)
                .frame(minWidth: 360, maxWidth: 360, minHeight: 220, maxHeight: 220)
        })
        .windowResizability(.contentSize)
    }

}
