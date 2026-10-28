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
    
    func wholePoints() -> some View {
        WholePointLayout { self }
    }
    
    @MainActor
    func renderAsImage() -> NSImage? {
        let probe = ImageRenderer(content: self)
        probe.scale = 2
        
        guard let probeImage = probe.cgImage
        else { return nil }
        
        let pointSize = NSSize(
            width: ceil(CGFloat(probeImage.width) / 2),
            height: ceil(CGFloat(probeImage.height) / 2))
        let content = self
            .fixedSize()
            .frame(width: pointSize.width, height: pointSize.height)
        let image = NSImage(size: pointSize)
        
        for scale in [1.0, 2.0] as [CGFloat] {
            let renderer = ImageRenderer(content: content)
            renderer.scale = scale
            
            guard let cg = renderer.cgImage
            else { continue }
            
            let rep = NSBitmapImageRep(cgImage: cg)
            rep.size = pointSize
            image.addRepresentation(rep)
        }
        
        return image.representations.isEmpty ? nil : image
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
