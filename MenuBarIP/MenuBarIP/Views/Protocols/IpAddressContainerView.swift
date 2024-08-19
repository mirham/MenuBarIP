//
//  IpAddressContainerView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI
import FlagKit

protocol IpAddressContainerView : View {}

extension IpAddressContainerView {
    func getMainColor(colorScheme: ColorScheme) -> Color {
        let result = colorScheme == .dark ? Color.white : Color.black
        
        return result
    }
    
    func getCountryFlag(countryCode: String) -> NSImage {
        return countryCode.isEmpty
        ? NSImage()
        : Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
