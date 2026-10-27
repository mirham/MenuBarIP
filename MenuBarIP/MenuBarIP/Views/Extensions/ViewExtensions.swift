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
    
    @MainActor
    func renderAsImage(scale: CGFloat) -> NSImage? {
        let hosting = NSHostingView(rootView: self)
        let fitting = hosting.fittingSize
        
        guard fitting.width > 0, fitting.height > 0
        else { return nil }
        
        let size = CGSize(
            width: ceil(fitting.width * scale) / scale,
            height: ceil(fitting.height * scale) / scale)
        
        let renderer = ImageRenderer(content: self.frame(
            width: size.width,
            height: size.height)
        )
        renderer.scale = scale
        
        guard let cgImage = renderer.cgImage
        else { return nil }
        
        return NSImage(cgImage: cgImage, size: size)
    }
    
    @ViewBuilder
    func safeGlassEffect() -> some View {
        if #available(macOS 26.0, *) {
            self.background(
                Color.clear
                    .glassEffect(.regular, in: Rectangle())
                    .ignoresSafeArea()
            )
        } else {
            self.background(Color.clear)
        }
    }
}

public extension NSView {
    func asImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds)
        else { return nil }
        
        cacheDisplay(in: bounds, to: rep)
        
        guard let cgImage = rep.cgImage
        else { return nil }
        
        let result = NSImage(cgImage: cgImage, size: bounds.size)
        
        return result
    }
}
