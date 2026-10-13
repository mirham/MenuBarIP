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
    init() {
        _ = Container.shared.windowRegistry()
        
        let lls = Container.shared.launchAgentService()
        lls.removeLegacyAgent()
    }
    
    var body: some Scene {
        return menuBar()
    }
    
    // MARK: View sections
    
    private func menuBar() -> some Scene {
        MenuBarExtra {
            MenuBarMenuView()
        } label: {
            HStack {
                MenuBarStatusView()
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
