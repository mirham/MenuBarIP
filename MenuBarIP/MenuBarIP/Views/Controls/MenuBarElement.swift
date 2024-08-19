//
//  MenuBarElement.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarElement: View, Equatable {
    let image: NSImage
    let id = UUID()
    let key: String
    let isSeparator: Bool
    let dateCreated: Date
    
    init(image: NSImage, key: String, isSeparator: Bool = false) {
        self.image = image
        self.key = key
        self.isSeparator = isSeparator
        self.dateCreated = Date()
    }
    
    var body: some View {
        Image(nsImage: image)
            .resizable()
            .frame(width: image.size.width, height: image.size.height)
    }
    
    func clone() -> MenuBarElement {
        let result = MenuBarElement(image: self.image, key: self.key, isSeparator: self.isSeparator)
        
        return result
    }
}
