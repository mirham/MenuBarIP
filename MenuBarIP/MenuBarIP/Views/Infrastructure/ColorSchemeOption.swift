//
//  ColorSchemeOption.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 28.10.2026.
//


import SwiftUI

enum ColorSchemeOption: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
            case .system: "System"
            case .light: "Light"
            case .dark: "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
            case .system: nil
            case .light: .light
            case .dark: .dark
        }
    }
    
    init(from decoder: Decoder) throws {
        let raw = try? decoder.singleValueContainer().decode(String.self)
        self = raw.flatMap(ColorSchemeOption.init(rawValue:)) ?? .system
    }
}

