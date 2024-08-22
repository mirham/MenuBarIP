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
    func getIpMainColor(
        colorScheme: ColorScheme,
        currentIpCustomization: IpCustomization?) -> Color {
            var result: Color = colorScheme == .dark ? .white : .black
            
            guard currentIpCustomization != nil else { return result }
            
            result = Color(hex: colorScheme == .dark
                           ? currentIpCustomization!.customDarkColor
                           : currentIpCustomization!.customLightColor)
            
            return result
        }
    
    func getCustomTextMainColor(
        colorScheme: ColorScheme,
        currentIpCustomization: IpCustomization?) -> Color {
            var result: Color = colorScheme == .dark ? .white : .black
            
            guard currentIpCustomization != nil else { return result }
            
            result = Color(hex: colorScheme == .dark
                           ? currentIpCustomization!.customTextDarkColor
                           : currentIpCustomization!.customTextLightColor)
            
            return result
        }
    
    func getCountryFlag(countryCode: String) -> NSImage {
        return countryCode.isEmpty
        ? NSImage()
        : Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
