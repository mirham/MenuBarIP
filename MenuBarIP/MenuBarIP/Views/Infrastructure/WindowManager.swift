//
//  WindowManager.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit

@MainActor
class WindowManager {
    private var builders: [WindowType: () -> NSView] = [:]
    private var controllers: [WindowType: WindowController] = [:]
    private var buildingWindows: Set<WindowType> = []
    private var openWindows: Set<WindowType> = []
    private var topLevelCounter: Int = NSWindow.Level.floating.rawValue
    
    func register(
        name: WindowType,
        builder: @escaping () -> NSView,
        size: CGSize? = nil,
        hideTitleBar: Bool = false,
        resizable: Bool = true) {
        builders[name] = builder
    }
    
    func open(
        name: WindowType,
        onTop: Bool = false) {
        if openWindows.contains(name) {
            controllers[name]?.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            
            return
        }
        
        guard !buildingWindows.contains(name)
        else { return }
        
        openWindows.insert(name)
        buildingWindows.insert(name)
        
        if controllers[name] == nil, let builder = builders[name] {
            let controller = WindowController(
                viewName: name.rawValue,
                contentView: builder(),
                size: name.size,
                hideTitleBar: name.hideTitleBar,
                resizable: name.resizable,
                glassTitlebar: name.glassTitlebar 
            )
            
            controller.window?.title = name.title
            
            controller.onWindowClosed = { [weak self] in
                self?.handleWindowClosed(name: name)
            }
            
            controllers[name] = controller
        }
        
        buildingWindows.remove(name)
            
        if onTop {
            topLevelCounter += 1
            controllers[name]?.window?.level = NSWindow.Level(
                rawValue: topLevelCounter)
        }
        
        controllers[name]?.open(
            onTop: onTop,
            hiddenButtons: name.hiddenButtons)
            
        updateActivationPolicy()
    }
    
    func setTopmost(name: WindowType, onTop: Bool) {
        topLevelCounter += 1
        controllers[name]?.setTopmost(onTop: onTop)
    }
    
    func close(name: WindowType) {
        controllers[name]?.close()
        controllers[name] = nil
        openWindows.remove(name)
    }
    
    // MARK: Private functions
    
    private func updateActivationPolicy() {
        let hasOpenWindows = !openWindows.isEmpty
        
        NSApp.setActivationPolicy(hasOpenWindows ? .regular : .accessory)
    }
    
    private func handleWindowClosed(name: WindowType) {
        controllers[name] = nil
        openWindows.remove(name)
        buildingWindows.remove(name)
        updateActivationPolicy()
    }
}
