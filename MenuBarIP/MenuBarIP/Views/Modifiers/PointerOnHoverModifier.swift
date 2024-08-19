//
//  PointerOnHoverModifier.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct PointerOnHoverModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.onHover(perform: { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        })
    }
}
