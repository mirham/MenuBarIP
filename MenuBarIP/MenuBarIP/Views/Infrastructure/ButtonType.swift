//
//  ButtonType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit

enum ButtonType {
    case zoom
    case miniaturize
    case close
    
    var button: NSWindow.ButtonType {
        switch self {
            case .zoom: return .zoomButton
            case .miniaturize: return .miniaturizeButton
            case .close: return .closeButton
        }
    }
}
