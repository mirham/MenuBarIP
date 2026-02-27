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
    @Binding var separatorInsertedDuringDrag: Bool
    
    let item: MenuBarElement
    let keepLastItem: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        
        let from = sourceItems.firstIndex(of: draggedItem)
        let to = sourceItems.firstIndex(of: item)
        ?? destinationItems.firstIndex(of: item)
        ?? 0
        
        withAnimation(.default) {
            if let from = from {
                sourceItems.move(
                    fromOffsets: IndexSet(integer: from),
                    toOffset: insertionIndex(to: to, from: from))
            } else {
                handleCrossListDrop(draggedItem: draggedItem, to: to)
            }
        }
    }
    
    // MARK: Private functions
    
    private func insertionIndex(to: Int, from: Int) -> Int {
        to > from ? (to == 0 ? to : to + 1) : to
    }
    
    private func handleCrossListDrop(draggedItem: MenuBarElement, to: Int) {
        if keepLastItem {
            guard destinationItems.count > 1
            else { return }

            if !draggedItem.isSeparator {
                sourceItems.insert(draggedItem, at: to == 0 ? to : to + 1)
            }
            
            destinationItems.removeAll(where: { $0.id == draggedItem.id })
        } else {
            guard !separatorInsertedDuringDrag || !draggedItem.isSeparator
            else { return }
            
            let itemToInsert = draggedItem.isSeparator
                ? draggedItem.clone()
                : draggedItem
            
            sourceItems.insert(itemToInsert, at: to == 0 ? to : to + 1)
            
            if draggedItem.isSeparator {
                separatorInsertedDuringDrag = true
            } else {
                destinationItems.removeAll(where: { $0.id == draggedItem.id })
            }
        }
    }
}
