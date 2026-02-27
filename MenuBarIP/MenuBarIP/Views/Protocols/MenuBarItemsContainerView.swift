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
        isExampleAllowed: Bool) -> [MenuBarElement]
}

extension MenuBarItemsContainerView {
    @MainActor
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        isExampleAllowed: Bool = false
    ) -> [MenuBarElement] {
        let colors = MenuBarColors(
            base: getBaseColor(colorScheme: colorScheme),
            ip: getIpColor(colorScheme: colorScheme, currentCustomization: appState.current.ipCustomization),
            customText: getCustomTextColor(
                colorScheme: colorScheme,
                primaryCustomization: appState.current.ipCustomization,
                optionalCustomization: appState.current.customTextCustomization),
            localIp: getIpColor(colorScheme: colorScheme, currentCustomization: appState.current.localIpCustomization),
            localIpCustomText: getCustomTextColor(
                colorScheme: colorScheme,
                primaryCustomization: appState.current.localIpCustomization,
                optionalCustomization: appState.current.customTextCustomization),
            useThemeColor: appState.userData.menuBarUseThemeColor
        )
        
        return keys.compactMap { key in
            createMenuBarElement(
                for: key,
                appState: appState,
                colors: colors,
                isExampleAllowed: isExampleAllowed
            )
        }
    }
    
    // MARK: Private functions
    
    @MainActor
    private func createMenuBarElement(
        for key: String,
        appState: AppState,
        colors: MenuBarColors,
        isExampleAllowed: Bool
    ) -> MenuBarElement? {
        let textSize = appState.userData.menuBarTextSize
        
        switch key {
            case Constants.mbItemKeyInternetStatus:
                return makeMenuBarItem(
                    key: key,
                    view: getInternetStatusItem(
                        networkStatus: appState.network.status,
                        hasNetworkAccess: appState.network.hasInternetAccess,
                        textSize: textSize
                    )
                )
                
            case Constants.mbItemKeyPublicIpAddress:
                return makeMenuBarItem(
                    key: key,
                    view: getIpAddressItem(
                        ipAddress: getEffectivePublicIpString(appState: appState),
                        color: colors.effectiveIpColor,
                        isExampleAllowed: isExampleAllowed,
                        isPublic: true,
                        hasNetworkAccess: appState.network.hasInternetAccess,
                        textSize: textSize
                    )
                )
                
            case Constants.mbItemKeyLocalIpAddress:
                return makeMenuBarItem(
                    key: key,
                    view: getIpAddressItem(
                        ipAddress: getEffectiveLocalIpString(appState: appState),
                        color: colors.effectiveLocalIpColor,
                        isExampleAllowed: isExampleAllowed,
                        isPublic: false,
                        hasNetworkAccess: true,
                        textSize: textSize
                    )
                )
                
            case Constants.mbItemKeyBothIpAddressesPublicUpper:
                return makeMenuBarItem(
                    key: key,
                    view: getBothIpAddressessItem(
                        ipAddressUpper: getEffectivePublicIpString(appState: appState),
                        ipAddressLower: getEffectiveLocalIpString(appState: appState),
                        colorUpper: colors.effectiveIpColor,
                        colorLower: colors.effectiveLocalIpColor,
                        isExampleAllowed: isExampleAllowed,
                        isPublicUpper: true,
                        hasNetworkAccess: appState.network.hasInternetAccess
                    )
                )
                
            case Constants.mbItemKeyCustomText:
                return makeMenuBarItem(
                    key: key,
                    view: getCustomTextItem(
                        customText: appState.current.publicIpCustomText ?? String(),
                        color: colors.effectiveCustomTextColor,
                        exampleAllowed: isExampleAllowed
                    )
                )
                
            case Constants.mbItemKeyPublicIpAddressWithCustomText:
                return makeMenuBarItem(
                    key: key,
                    view: getIpAddressWithCustomTextItem(
                        ipAddress: getEffectivePublicIpString(appState: appState),
                        customText: appState.current.publicIpCustomText ?? String(),
                        color: colors.effectiveIpColor,
                        customTextColor: colors.effectiveCustomTextColor,
                        hasNetworkAccess: appState.network.hasInternetAccess,
                        textSize: textSize,
                        isPublic: true,
                        isExampleAllowed: isExampleAllowed
                    )
                )
                
            case Constants.mbItemKeyLocalIpAddressWithCustomText:
                return makeMenuBarItem(
                    key: key,
                    view: getIpAddressWithCustomTextItem(
                        ipAddress: getEffectiveLocalIpString(appState: appState),
                        customText: appState.current.localIpCustomization?.customText ?? String(),
                        color: colors.effectiveLocalIpColor,
                        customTextColor: colors.effectiveLocalIpCustomTextColor,
                        hasNetworkAccess: appState.network.hasInternetAccess,
                        textSize: textSize,
                        isPublic: false,
                        isExampleAllowed: isExampleAllowed
                    )
                )
                
            case Constants.mbItemKeyCountryCode:
                return makeMenuBarItem(
                    key: key,
                    view: getCountryCodeItem(
                        countryCode: appState.network.publicIp?.countryCode ?? String(),
                        color: colors.effectiveIpColor,
                        exampleAllowed: isExampleAllowed,
                        textSize: textSize
                    )
                )
                
            case Constants.mbItemKeyCountryFlag:
                return makeMenuBarItemWithImage(
                    key: key,
                    image: getCountryFlagItem(
                        countryCode: appState.network.publicIp?.countryCode ?? String(),
                        isExampleAllowed: isExampleAllowed,
                        textSize: textSize
                    )
                )
                
            case Constants.mbItemKeyBigCountryFlag:
                return makeMenuBarItemWithImage(
                    key: key,
                    image: getCountryFlagItem(
                        countryCode: appState.network.publicIp?.countryCode ?? String(),
                        isExampleAllowed: isExampleAllowed,
                        scalable: false
                    )
                )
                
            case Constants.mbItemKeySeparatorBullet:
                return makeSeparatorItem(
                    key: key,
                    view: getBulletItem(color: colors.base, textSize: textSize)
                )
                
            case Constants.mbItemKeySeparatorBigBullet:
                return makeSeparatorItem(
                    key: key,
                    view: getBulletItem(color: colors.base, textSize: 16.0)
                )
                
            case Constants.mbItemKeySeparatorPipe:
                return makeSeparatorItem(
                    key: key,
                    view: getPipeItem(color: colors.base, textSize: textSize)
                )
                
            case Constants.mbItemKeySeparatorLeftBracket:
                return makeSeparatorItem(
                    key: key,
                    view: getLeftBracketItem(color: colors.base, textSize: textSize)
                )
                
            case Constants.mbItemKeySeparatorRightBracket:
                return makeSeparatorItem(
                    key: key,
                    view: getRightBracketItem(color: colors.base, textSize: textSize)
                )
                
            default:
                return nil
        }
    }
    
    @MainActor
    private func makeMenuBarItem(key: String, view: some View) -> MenuBarElement {
        MenuBarElement(
            image: renderMenuBarItemImage(view: view),
            key: key
        )
    }
    
    @MainActor
    private func makeMenuBarItemWithImage(key: String, image: NSImage) -> MenuBarElement {
        MenuBarElement(
            image: image,
            key: key
        )
    }
    
    @MainActor
    private func makeSeparatorItem(key: String, view: some View) -> MenuBarElement {
        MenuBarElement(
            image: renderMenuBarItemImage(view: view),
            key: key,
            isSeparator: true
        )
    }
    
    private func getEffectivePublicIpString(appState: AppState) -> String {
        return appState.network.status == .off
            ? Constants.offline
            : appState.network.isObtainingIp
                ? Constants.obtainingIp
                : appState.network.publicIp?.ipAddress ?? Constants.none
    }
    
    private func getEffectiveLocalIpString(appState: AppState) -> String {
        return appState.network.localIp == nil
            ? Constants.none
            : appState.network.localIp!
    }
    
    @MainActor
    private func renderMenuBarItemImage(view: some View) -> NSImage {
        let renderer = ImageRenderer(content: view)
        let result = renderer.nsImage ?? NSImage()
        
        return result
    }
    
    private func getIpAddressItem(
        ipAddress: String,
        color: Color,
        isExampleAllowed: Bool,
        isPublic: Bool,
        hasNetworkAccess: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        let noIpAddress = ipAddress.isEmpty
            || ipAddress == Constants.none
            || ipAddress == Constants.offline
            || ipAddress == Constants.obtainingIp
        let effectiveIpAddress = noIpAddress && isExampleAllowed
            ? isPublic
                ? Constants.defaultPublicIpAddress
                : Constants.defaultLocalIpAddress
            : ipAddress
        
        if hasNetworkAccess || isExampleAllowed {
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
        isExampleAllowed: Bool,
        isPublicUpper: Bool,
        hasNetworkAccess: Bool) -> some View {
        let upperItem = getIpAddressItem(
            ipAddress: ipAddressUpper,
            color: colorUpper,
            isExampleAllowed: isExampleAllowed,
            isPublic: isPublicUpper,
            hasNetworkAccess: hasNetworkAccess,
            textSize: 9)
        let lowerItem = getIpAddressItem(
            ipAddress: ipAddressLower,
            color: colorLower,
            isExampleAllowed: isExampleAllowed,
            isPublic: !isPublicUpper,
            hasNetworkAccess: true,
            textSize: 9)
            
            let result = VStack(alignment: .leading, spacing: -2) {
            upperItem
            lowerItem
        }
            
        return result
    }
    
    private func getIpAddressWithCustomTextItem(
        ipAddress: String,
        customText: String,
        color: Color,
        customTextColor: Color,
        hasNetworkAccess: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize,
        isPublic: Bool,
        isExampleAllowed: Bool) -> any View {
        if !isExampleAllowed && customText.isEmpty {
            return getIpAddressItem(
                ipAddress: ipAddress,
                color: color,
                isExampleAllowed: isExampleAllowed,
                isPublic: isPublic,
                hasNetworkAccess: hasNetworkAccess,
                textSize: textSize)
        }
            
        let upperItem = getCustomTextItem(
            customText: customText,
            color: customTextColor,
            exampleAllowed: isExampleAllowed,
            textSize: 7)
        let lowerItem = getIpAddressItem(
            ipAddress: ipAddress,
            color: color,
            isExampleAllowed: isExampleAllowed,
            isPublic: isPublic,
            hasNetworkAccess: hasNetworkAccess,
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
        isExampleAllowed: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize,
        scalable: Bool = true) -> NSImage {
        let scale = scalable ? 0.9 * textSize / 16 :  0.9
        let effectiveCountryCode = countryCode.isEmpty && isExampleAllowed
            ? Constants.defaultCountryCode
            : countryCode
        let result = getCountryFlag(countryCode: effectiveCountryCode)
        result.size.width = result.size.width * scale
        result.size.height = result.size.height * scale
        
        return result
    }
    
    private func getInternetStatusItem(
        networkStatus: NetworkStatusType,
        hasNetworkAccess: Bool,
        textSize: Double = Constants.defaultMenuBarTextSize) -> some View {
            let color: Color = networkStatus == .on && hasNetworkAccess
                ? .green
                : networkStatus != .off
                    ? .orange
                    : .red
            
            let scale = 1 * textSize / 16
            let result = Circle()
                .fill(color)
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

private struct MenuBarColors {
    let base: Color
    let ip: Color
    let customText: Color
    let localIp: Color
    let localIpCustomText: Color
    let useThemeColor: Bool
    
    var effectiveIpColor: Color { useThemeColor ? base : ip }
    var effectiveCustomTextColor: Color { useThemeColor ? base : customText }
    var effectiveLocalIpColor: Color { useThemeColor ? base : localIp }
    var effectiveLocalIpCustomTextColor: Color { useThemeColor ? base : localIpCustomText }
}

private extension Text {
    func asMenuBarItem(
        color: Color,
        textSize: Double = Constants.defaultMenuBarTextSize) -> Text {
        self.font(.system(size: textSize))
            .foregroundColor(color)
    }
}
