//
//  DropViewDelegate.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

struct DropViewDelegate: DropDelegate {
    @Binding var draggedItem: MenuBarElement?
    @Binding var sourceItems: [MenuBarElement]
    @Binding var destinationItems: [MenuBarElement]
    
    let item: MenuBarElement
    let keepLastItem: Bool
    
    private let start = 0
    private let step = 1
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        let from = sourceItems.firstIndex(of: draggedItem) != nil ? sourceItems.firstIndex(of: draggedItem) : nil
        let to = sourceItems.firstIndex(of: item) != nil ? sourceItems.firstIndex(of: item)! : start
        
        withAnimation(.default) {
            if(from != nil) {
                sourceItems.move(
                    fromOffsets: IndexSet(integer: from!),
                    toOffset: to > from! ? to == start ? to : to + step : to)
            }
            else {
                if (keepLastItem) {
                    if (destinationItems.count == step) {
                        return
                    }
                    else {
                        if (!draggedItem.isSeparator) {
                            sourceItems.insert(draggedItem, at: to == start ? to : to + step)
                        }
                        
                        destinationItems.removeAll(where: {$0.id == draggedItem.id })
                    }
                }
                else {
                    if (!sourceItems.contains(where: {Int(Date().timeIntervalSince($0.dateCreated))
                        < Constants.menuBarItemTimeToleranceInSeconds })) {
                        let item = draggedItem.isSeparator ? draggedItem.clone() : draggedItem
                        sourceItems.insert(item, at: to == start ? to : to + step)
                        destinationItems.removeAll(where: {$0.id == item.id})
                    }
                }
            }
        }
    }
}
