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
    @Injected(\.appState) private var appState
    
    init() {
        _ = Container.shared.windowRegistry()
    }
    
    var body: some Scene {
        let appState = Container.shared.appState()
        
        return menuBar(appState: appState)
    }
    
    // MARK: View sections
    
    private func menuBar(appState: AppState) -> some Scene {
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
    }

}
