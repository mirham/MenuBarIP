//
//  ImageExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

extension Image {
    func nonAntialiased () -> Image {
        self.interpolation(.none)
            .antialiased(false)
    }
    
    func asInfoIcon() -> some View {
        self.resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
            .padding(.top)
            .padding(.leading)
    }
}
