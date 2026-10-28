//
//  ColorSchemePicker.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 28.10.2026.
//

import SwiftUI
import Factory

struct ColorSchemePicker: View {
    @Injected(\.appAppearance) private var appearance
    
    @Binding var selection: ColorSchemeOption
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Picker(String(), selection: $selection) {
                ForEach(ColorSchemeOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: selection) { _, newValue in
                appearance.apply(newValue)
            }
        }
    }
}

