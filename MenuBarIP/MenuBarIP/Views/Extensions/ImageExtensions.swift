//
//  ImageExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

extension Image {
    func asInfoIcon() -> some View {
        self.resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
            .padding(.top)
            .padding(.leading)
    }
}


extension NSImage {
    func pixelSnapped(to points: NSSize, scale: CGFloat) -> NSImage {
        let pixelsWide = max(Int((points.width * scale).rounded()), 1)
        let pixelsHigh = max(Int((points.height * scale).rounded()), 1)
        let snappedSize = NSSize(width: CGFloat(pixelsWide) / scale,
                                 height: CGFloat(pixelsHigh) / scale)
        
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelsWide,
            pixelsHigh: pixelsHigh,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0),
              let context = NSGraphicsContext(bitmapImageRep: rep)
        else { return self }
        
        rep.size = snappedSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: snappedSize),
             from: .zero,
             operation: .copy,
             fraction: 1)
        NSGraphicsContext.restoreGraphicsState()
        
        let result = NSImage(size: snappedSize)
        result.addRepresentation(rep)
        
        return result
    }
}
