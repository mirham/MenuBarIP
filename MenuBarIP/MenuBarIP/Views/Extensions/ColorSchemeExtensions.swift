//
//  ColorSchemeExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 27.10.2026.
//

import SwiftUI

extension ColorScheme {
    var inverted: ColorScheme { self == .dark ? .light : .dark }
}
