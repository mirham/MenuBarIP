//
//  FixedSegmentedPicker.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 15.10.2026.
//

import SwiftUI

struct FixedSegmentedPicker<T: Hashable>: NSViewRepresentable {
    let items: [T]
    let title: (T) -> String
    @Binding var selection: T
    let width: CGFloat
    
    func makeNSView(context: Context) -> NSSegmentedControl {
        let control = NSSegmentedControl(
            labels: items.map(title),
            trackingMode: .selectOne,
            target: context.coordinator,
            action: #selector(Coordinator.changed(_:)))
        control.segmentDistribution = .fillEqually
        control.widthAnchor.constraint(equalToConstant: width).isActive = true
      
        return control
    }
    
    func updateNSView(_ control: NSSegmentedControl, context: Context) {
        context.coordinator.parent = self
        
        if let index = items.firstIndex(of: selection) {
            control.selectedSegment = index
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    final class Coordinator: NSObject {
        var parent: FixedSegmentedPicker
        
        init(_ parent: FixedSegmentedPicker) {
            self.parent = parent
        }
        
        @objc func changed(_ sender: NSSegmentedControl) {
            parent.selection = parent.items[sender.selectedSegment]
        }
    }
}
