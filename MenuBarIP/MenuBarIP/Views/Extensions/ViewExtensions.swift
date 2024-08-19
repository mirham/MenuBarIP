//
//  ViewExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

extension View {
    func isHidden(hidden: Bool = false, remove: Bool = false) -> some View {
        modifier(IsHiddenModifier(hidden: hidden, remove: remove))
    }
    
    func pointerOnHover() -> some View {
        modifier(PointerOnHoverModifier())
    }
    
    func getViewOpacity(state: ControlActiveState) -> Double {
        return state == .key ? 1 : 0.6
    }
    
    func renderAsImage() -> NSImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        
        let result = view.asImage()
        
        return result
    }
}

public extension NSView {
    func asImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        
        cacheDisplay(in: bounds, to: rep)
        
        guard let cgImage = rep.cgImage else {
            return nil
        }
        
        let result = NSImage(cgImage: cgImage, size: bounds.size)
        
        return result
    }
}
