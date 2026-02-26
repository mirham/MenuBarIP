//
//  CustomizableItemsContainerView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 25.02.2026.
//

import SwiftUI

protocol CustomizableItemsContainerView : View {}

extension CustomizableItemsContainerView {
    func getBaseColor(
        colorScheme: ColorScheme,
        forMenu: Bool = false) -> Color {
        let result: Color = colorScheme == .dark
            ? forMenu
                ? Color(hex: Constants.defaultLightColor)
                : .white
            : forMenu
                ? Color(hex: Constants.defaultDarkColor)
                : .black
            
        return result
    }
    
    func getIpColor(
        colorScheme: ColorScheme,
        currentCustomization: Customization?,
        forMenu: Bool = false) -> Color {
            var result: Color = getBaseColor(colorScheme: colorScheme, forMenu: forMenu)
            
            guard currentCustomization != nil
            else { return result }
            
            result = Color(hex: colorScheme == .dark
                           ? currentCustomization!.customDarkColor
                           : currentCustomization!.customLightColor)
            
            return result
        }
    
    func getCustomTextColor(
        colorScheme: ColorScheme,
        primaryCustomization: Customization?,
        optionalCustomization: Customization?) -> Color {
            var result: Color = getBaseColor(colorScheme: colorScheme)
                        
            let effectiveCustomization = primaryCustomization ?? optionalCustomization
            
            guard let effectiveCustomization = effectiveCustomization
            else { return result }
            
            result = Color(hex: colorScheme == .dark
                           ? effectiveCustomization.customTextDarkColor
                           : effectiveCustomization.customTextLightColor)
            
            return result
        }
}
