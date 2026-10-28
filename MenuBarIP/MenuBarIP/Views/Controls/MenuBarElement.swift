//
//  MenuBarElement.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarElement: View, Equatable {
    let content: AnyView
    let id = UUID()
    let key: String
    let isSeparator: Bool
    let dateCreated: Date
    
    @MainActor
    var image: NSImage { content.renderAsImage() ?? NSImage() }
    
    init(content: AnyView, key: String, isSeparator: Bool = false) {
        self.content = content
        self.key = key
        self.isSeparator = isSeparator
        self.dateCreated = Date()
    }
    
    var body: some View {
        content
    }
    
    func clone() -> MenuBarElement {
        MenuBarElement(
            content: content,
            key: key,
            isSeparator: isSeparator)
    }
    
    static func == (lhs: MenuBarElement, rhs: MenuBarElement) -> Bool {
        lhs.id == rhs.id
    }
}
