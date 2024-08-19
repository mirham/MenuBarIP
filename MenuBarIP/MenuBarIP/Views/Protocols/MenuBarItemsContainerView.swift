//
//  MenuBarItemsContainerView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

protocol MenuBarItemsContainerView : IpAddressContainerView {
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool) -> [MenuBarElement]
}

extension MenuBarItemsContainerView {
    @MainActor
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool = false) -> [MenuBarElement] {
            var result = [MenuBarElement]()
            
            let baseColor = colorScheme == .dark ? Color.white : Color.black
            let mainColor = getMainColor(colorScheme: colorScheme)
            
            for key in keys {
                switch key {
                    case Constants.mbItemKeyIpAddress:
                        let ipAddress = getIpAddressItem(
                            ipAddress: appState.network.currentIpInfo == nil
                            ? Constants.none
                            : appState.network.currentIpInfo!.ipAddress,
                            color: mainColor,
                            exampleAllowed: exampleAllowed)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: ipAddress), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyCountryCode:
                        let countryCode = getCountryCodeItem(
                            countryCode: appState.network.currentIpInfo == nil
                            ? String()
                            : appState.network.currentIpInfo!.countryCode,
                            color: mainColor,
                            exampleAllowed: exampleAllowed)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: countryCode), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyCountryFlag:
                        let countryFlag = getCountryFlagItem(
                            countryCode: appState.network.currentIpInfo == nil
                            ? String()
                            : appState.network.currentIpInfo!.countryCode,
                            exampleAllowed: exampleAllowed)
                        let menuBarItem = MenuBarElement(image: countryFlag, key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorBullet:
                        let bullet = getBulletItem(color: baseColor)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: bullet), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorBigBullet:
                        let bigBullet = getBulletItem(color: baseColor, textSize: 16.0)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: bigBullet), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorPipe:
                        let pipe = getPipeItem(color: baseColor)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: pipe), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorLeftBracket:
                        let leftBracket = getLeftBracketItem(color: baseColor)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: leftBracket), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorRightBracket:
                        let rightBracket = getRightBracketItem(color: baseColor)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: rightBracket), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    default:
                        break
                }
            }
            
            return result
        }
    
    // MARK: Private functions
    @MainActor
    private func renderMenuBarItemImage(view: some View) -> NSImage {
        let renderer = ImageRenderer(content: view)
        let result = renderer.nsImage ?? NSImage()
        
        return result
    }
    
    private func getIpAddressItem(ipAddress: String, color: Color, exampleAllowed: Bool) -> Text {
        let effectiveIpAddress = (ipAddress.isEmpty || ipAddress == Constants.none) && exampleAllowed
        ? Constants.defaultIpAddress
        : ipAddress
        
        let result = Text(effectiveIpAddress.uppercased())
            .asMenuBarItem(color: color)
        
        return result
    }
    
    private func getCountryCodeItem(countryCode: String, color: Color, exampleAllowed: Bool) -> Text {
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        
        let result = Text(effectiveCountryCode.uppercased())
            .asMenuBarItem(color: color)
        
        return result
    }
    
    private func getCountryFlagItem(countryCode: String, exampleAllowed: Bool) -> NSImage {
        let scale = 0.9
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        let result = getCountryFlag(countryCode: effectiveCountryCode)
        result.size.width = result.size.width * scale
        result.size.height = result.size.height * scale
        
        return result
    }
    
    private func getBulletItem(color: Color, textSize: Double = 12.0) -> Text {
        let result = Text(Constants.bullet)
            .asMenuBarItem(color: color, textSize: textSize)
        
        return result
    }
    
    private func getPipeItem(color: Color) -> Text {
        let result = Text(Constants.pipe)
            .asMenuBarItem(color: color)
        
        return result
    }
    
    private func getLeftBracketItem(color: Color) -> Text {
        let result = Text(Constants.leftBracket)
            .asMenuBarItem(color: color)
        
        return result
    }
    
    private func getRightBracketItem(color: Color) -> Text {
        let result = Text(Constants.rightBracket)
            .asMenuBarItem(color: color)
        
        return result
    }
}

private extension Text {
    func asMenuBarItem(color: Color, textSize: Double = 16.0) -> Text {
        self.font(.system(size: textSize))
            .foregroundColor(color)
    }
}
