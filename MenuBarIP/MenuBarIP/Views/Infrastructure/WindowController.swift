//
//  WindowController.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit

@MainActor
class WindowController: NSWindowController, NSWindowDelegate {
    var onWindowClosed: (() -> Void)?
    
    convenience init(
        viewName: String,
        contentView: NSView,
        size: CGSize? = nil,
        hideTitleBar: Bool = false,
        resizable: Bool = true,
        glassTitlebar: Bool = false) {
        var styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
        
        if resizable {
            styleMask.insert(.resizable)
        }
        
        if hideTitleBar {
            styleMask.insert(.fullSizeContentView)
        }
        
        let window = NSWindow(
            contentRect: .zero,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        window.identifier = NSUserInterfaceItemIdentifier(viewName)
        window.contentView = contentView
            
        if glassTitlebar {
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
        }
        
        if hideTitleBar {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
        }
        
        if let size {
            window.setContentSize(size)
        } else {
            window.setContentSize(contentView.fittingSize)
        }
        
        window.center()
        self.init(window: window)
        window.delegate = self
    }
    
    func open(onTop: Bool = false, hiddenButtons: [ButtonType] = []) {
        guard let window
        else { return }
        
        configure(onTop: onTop, hiddenButtons: hiddenButtons)
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        if onTop {
            window.level = .floating
            window.orderFrontRegardless()
        }
    }
    
    func setTopmost(onTop: Bool) {
        guard let window
        else { return }
        
        window.level = onTop ? .floating : .normal
        window.collectionBehavior = onTop
            ? [.canJoinAllSpaces, .fullScreenAuxiliary]
            : []
        
        if onTop {
            window.orderFrontRegardless()
        }
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        window?.contentView?.needsDisplay = true
        window?.contentView?.needsLayout = true
    }
    
    func windowWillClose(_ notification: Notification) {
        onWindowClosed?()
    }
    
    // MARK: Private functions
    
    private func configure(onTop: Bool, hiddenButtons: [ButtonType]) {
        guard let window
        else { return }
        
        window.level = onTop ? .floating : .normal
        window.collectionBehavior = onTop
        ? [.canJoinAllSpaces, .fullScreenAuxiliary]
        : []
        
        hiddenButtons.forEach {
            window.standardWindowButton($0.button)?.isHidden = true
        }
    }
}
