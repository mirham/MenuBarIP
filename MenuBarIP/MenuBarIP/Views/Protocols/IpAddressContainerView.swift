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
    func getBaseColor(
        colorScheme: ColorScheme,
        forMenu: Bool = false) -> Color {
        let result: Color = colorScheme == .dark
            ? forMenu
                ? Color(hex: "#FEFFFF")
                : .white
            : forMenu
                ? Color(hex: "#000001")
                : .black
            
        return result
    }
    
    func getIpMainColor(
        colorScheme: ColorScheme,
        currentIpCustomization: IpCustomization?,
        forMenu: Bool = false) -> Color {
            var result: Color = getBaseColor(colorScheme: colorScheme, forMenu: forMenu)
            
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
