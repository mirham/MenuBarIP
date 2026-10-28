//
//  NSScreenExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 28.10.2026.
//

import AppKit

extension NSScreen {
    static var renderScale: CGFloat {
        max(NSScreen.screens.map(\.backingScaleFactor).max() ?? 2, 2)
    }
}
