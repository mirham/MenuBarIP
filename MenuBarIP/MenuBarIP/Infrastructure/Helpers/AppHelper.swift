//
//  AppHelper.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

class AppHelper {
    static func setUpView(viewName: String, onTop: Bool) {
        for window in NSApplication.shared.windows {
            let windowId = String(window.identifier?.rawValue ?? String())
            
            if(windowId.starts(with: viewName)) {
                window.level = onTop ? .floating : .normal
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
        }
    }
    
    static func activateView(viewId: String) {
        for window in NSApplication.shared.windows {
            let windowId = String(window.identifier?.rawValue ?? String())
            
            if(windowId.starts(with: viewId)) {
                NSApplication.shared.activate(ignoringOtherApps: true)
                //window.makeKeyAndOrderFront(nil)
                //window.orderFrontRegardless()
            }
        }
    }
    
    static func closeView(viewName: String) {
        for window in NSApplication.shared.windows {
            let windowId = String(window.identifier?.rawValue ?? String())
            
            if(windowId.starts(with: viewName)) {
                window.close()
            }
        }
    }
    
    static func copyTextToClipboard(text : String) {
        guard !text.isEmpty else { return }
        
        NSPasteboard.general.declareTypes([.string], owner: nil)
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
