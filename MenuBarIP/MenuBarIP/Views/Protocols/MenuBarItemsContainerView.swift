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
            
            let baseColor = getBaseColor(colorScheme: colorScheme)
            let ipColor = appState.userData.menuBarUseThemeColor
                ? baseColor
                : getIpColor(colorScheme: colorScheme, currentIpCustomization: appState.current.ipCustomization)
            let customTextColor = appState.userData.menuBarUseThemeColor
                ? baseColor
                : getCustomTextColor(colorScheme: colorScheme, currentIpCustomization: appState.current.ipCustomization)
            
            for key in keys {
                switch key {
                    case Constants.mbItemKeyInternetStatus:
                        let internetAccess = getInternetStatusItem(
                            internetAccess: appState.network.internetAccess,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: internetAccess), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyPublicIpAddress:
                        let publicIpAddress = getIpAddressItem(
                            ipAddress: appState.network.publicIpInfo == nil
                                ? Constants.none
                                : appState.network.publicIpInfo!.ipAddress,
                            color: ipColor,
                            exampleAllowed: exampleAllowed,
                            isPublic: true,
                            networkAccess: appState.network.internetAccess,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: publicIpAddress), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyLocalIpAddress:
                        let localIpAddress = getIpAddressItem(
                            ipAddress: appState.network.localIp == nil
                                ? Constants.none
                                : appState.network.localIp!,
                            color: baseColor,
                            exampleAllowed: exampleAllowed,
                            isPublic: false,
                            networkAccess: true,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: localIpAddress), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyBothIpAddressesPublicUpper:
                        let view = getBothIpAddressessItem(
                            ipAddressUpper: appState.network.publicIpInfo == nil
                                ? Constants.none
                                : appState.network.publicIpInfo!.ipAddress,
                            ipAddressLower: appState.network.localIp == nil
                                ? Constants.none
                                : appState.network.localIp!,
                            colorUpper: ipColor,
                            colorLower: baseColor,
                            exampleAllowed: exampleAllowed,
                            isPublicUpper: true,
                            networkAccess: appState.network.internetAccess)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: view), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyCustomText:
                        let view = getCustomTextItem(
                            customText: appState.current.ipCustomization?.customText ?? String(),
                            color: customTextColor,
                            exampleAllowed: exampleAllowed)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: view), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyPublicIpAddressWithCustomText:
                        let view = getPublicIpAddressWithCustomTextItem(
                            ipAddress: appState.network.publicIpInfo == nil
                                ? Constants.none
                                : appState.network.publicIpInfo!.ipAddress,
                            customText: appState.current.ipCustomization?.customText ?? String(),
                            color: ipColor,
                            customTextColor: customTextColor,
                            networkAccess: appState.network.internetAccess,
                            textSize: appState.userData.menuBarTextSize,
                            exampleAllowed: exampleAllowed)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: view), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyCountryCode:
                        let countryCode = getCountryCodeItem(
                            countryCode: appState.network.publicIpInfo == nil
                            ? String()
                            : appState.network.publicIpInfo!.countryCode,
                            color: ipColor,
                            exampleAllowed: exampleAllowed,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: countryCode), key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyCountryFlag:
                        let countryFlag = getCountryFlagItem(
                            countryCode: appState.network.publicIpInfo == nil
                            ? String()
                            : appState.network.publicIpInfo!.countryCode,
                            exampleAllowed: exampleAllowed,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: countryFlag, key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeyBigCountryFlag:
                        let countryFlag = getCountryFlagItem(
                            countryCode: appState.network.publicIpInfo == nil
                            ? String()
                            : appState.network.publicIpInfo!.countryCode,
                            exampleAllowed: exampleAllowed,
                            scalable: false)
                        let menuBarItem = MenuBarElement(image: countryFlag, key: key)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorBullet:
                        let bullet = getBulletItem(
                            color: baseColor,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: bullet), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorBigBullet:
                        let bigBullet = getBulletItem(
                            color: baseColor,
                            textSize: 16.0)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: bigBullet), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorPipe:
                        let pipe = getPipeItem(
                            color: baseColor,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: pipe), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorLeftBracket:
                        let leftBracket = getLeftBracketItem(
                            color: baseColor,
                            textSize: appState.userData.menuBarTextSize)
                        let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: leftBracket), key: key, isSeparator: true)
                        result.append(menuBarItem)
                    case Constants.mbItemKeySeparatorRightBracket:
                        let rightBracket = getRightBracketItem(
                            color: baseColor,
                            textSize: appState.userData.menuBarTextSize)
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
    
    private func getIpAddressItem(
        ipAddress: String,
        color: Color,
        exampleAllowed: Bool,
        isPublic: Bool,
        networkAccess: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let effectiveIpAddress = (ipAddress.isEmpty || ipAddress == Constants.none) && exampleAllowed
            ? isPublic
                ? Constants.defaultPublicIpAddress
                : Constants.defaultLocalIpAddress
            : ipAddress
        
        if (networkAccess || exampleAllowed) {
            let result = Text(effectiveIpAddress.uppercased())
                .asMenuBarItem(color: color, textSize: textSize)
            return result
        }
        else {
            let result = Text(Constants.noInternet.uppercased())
                .asMenuBarItem(color: .red, textSize: textSize)
            return result
        }
    }
    
    private func getCustomTextItem(
        customText: String,
        color: Color,
        exampleAllowed: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
            let effectiveCustomText = customText.isEmpty && exampleAllowed
            ? Constants.customText
            : customText
            
            let result = Text(effectiveCustomText.uppercased())
                .asMenuBarItem(color: color, textSize: textSize)
            
            return result
        }
    
    private func getBothIpAddressessItem(
        ipAddressUpper: String,
        ipAddressLower: String,
        colorUpper: Color,
        colorLower: Color,
        exampleAllowed: Bool,
        isPublicUpper: Bool,
        networkAccess: Bool) -> some View {
        let upperItem = getIpAddressItem(
            ipAddress: ipAddressUpper,
            color: colorUpper,
            exampleAllowed: exampleAllowed,
            isPublic: isPublicUpper,
            networkAccess: networkAccess,
            textSize: 9)
        let lowerItem = getIpAddressItem(
            ipAddress: ipAddressLower,
            color: colorLower,
            exampleAllowed: exampleAllowed,
            isPublic: !isPublicUpper,
            networkAccess: true,
            textSize: 9)
            
            let result = VStack(alignment: .leading, spacing: -2) {
            upperItem
            lowerItem
        }
            
        return result
    }
    
    private func getPublicIpAddressWithCustomTextItem(
        ipAddress: String,
        customText: String,
        color: Color,
        customTextColor: Color,
        networkAccess: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize,
        exampleAllowed: Bool) -> any View {
            if (!exampleAllowed && customText.isEmpty) {
                return getIpAddressItem(
                    ipAddress: ipAddress,
                    color: color,
                    exampleAllowed: exampleAllowed,
                    isPublic: true,
                    networkAccess: networkAccess,
                    textSize: textSize)
            }
            
            let upperItem = getCustomTextItem(
                customText: customText,
                color: customTextColor,
                exampleAllowed: exampleAllowed,
                textSize: 7)
            let lowerItem = getIpAddressItem(
                ipAddress: ipAddress,
                color: color,
                exampleAllowed: exampleAllowed,
                isPublic: true,
                networkAccess: networkAccess,
                textSize: 12)
            
            let result = VStack(alignment: .leading, spacing: -3) {
                upperItem
                lowerItem
            }
            
            return result
        }
    
    private func getCountryCodeItem(
        countryCode: String,
        color: Color,
        exampleAllowed: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        
        let result = Text(effectiveCountryCode.uppercased())
            .asMenuBarItem(color: color, textSize: textSize)
        
        return result
    }
    
    private func getCountryFlagItem(
        countryCode: String,
        exampleAllowed: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize,
        scalable: Bool = true) -> NSImage {
        let scale = scalable ? 0.9 * textSize / 16 :  0.9
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        let result = getCountryFlag(countryCode: effectiveCountryCode)
        result.size.width = result.size.width * scale
        result.size.height = result.size.height * scale
        
        return result
    }
    
    private func getInternetStatusItem(
        internetAccess: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize) -> some View {
            let scale = 1 * textSize / 16
            let result = Circle()
                .fill(internetAccess ? .green : .red)
                .frame(width: 20, height: 20)
                .overlay(content: {
                    Circle()
                        .stroke(Color.primary, lineWidth: 1)
                        .padding(1)
                })
                .scaleEffect(scale)
            
            return result
        }
    
    private func getBulletItem(
        color: Color,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let result = Text(Constants.bullet)
            .asMenuBarItem(color: color, textSize: textSize)
        
        return result
    }
    
    private func getPipeItem(
        color: Color,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let result = Text(Constants.pipe)
            .asMenuBarItem(color: color, textSize: textSize)
        
        return result
    }
    
    private func getLeftBracketItem(
        color: Color,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let result = Text(Constants.leftBracket)
            .asMenuBarItem(color: color, textSize: textSize)
        
        return result
    }
    
    private func getRightBracketItem(
        color: Color,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let result = Text(Constants.rightBracket)
            .asMenuBarItem(color: color, textSize: textSize)
        
        return result
    }
}

private extension Text {
    func asMenuBarItem(color: Color, textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        self.font(.system(size: textSize))
            .foregroundColor(color)
    }
}
