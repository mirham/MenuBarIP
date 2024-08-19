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
            VStack{
                MenuBarView()
                    .environmentObject(appState)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(.windowBackground)
        } label: {
            HStack {
                MenuBarStatusView()
                    .environmentObject(appState)
            }
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id:Constants.windowIdSettings, content: {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.settings)
                .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
    }
}
