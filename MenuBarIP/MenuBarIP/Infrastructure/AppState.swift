//
//  AppState.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

class AppState : ObservableObject {
    @Published var current = Current()
    @Published var views = Views(shownWindows: [String()])
    @Published var network = Network() { didSet { setCurrentState() } }
    @Published var userData = UserData()  { didSet { setCurrentState() } }
    
    static let shared = AppState()
    
    func applyNetworkUpdate(_ update: NetworkStateUpdate) {
        var updatedNetwork = Network()
        
        if update.status != nil {
            updatedNetwork.status = update.status!
            
            if network.status != .on && update.status == .on {
                reactivateIpApis()
            }
        }
        else {
            updatedNetwork.status = network.status
        }
        
        updatedNetwork.publicIp = update.forceUpdatePublicIp ? update.publicIp : network.publicIp
        updatedNetwork.localIp = update.localIp ?? network.localIp
        updatedNetwork.activeNetworkInterfaces = update.activeNetworkInterfaces ?? network.activeNetworkInterfaces
        updatedNetwork.isObtainingIp = update.isObtainingIp ?? network.isObtainingIp
        updatedNetwork.hasInternetAccess = update.hasInternetAccess ?? network.hasInternetAccess
        
        if network != updatedNetwork {
            network = updatedNetwork
        }
    }
    
    // MARK: Private functions
    
    private func setCurrentState() {
        guard network.publicIp != nil else {
            current.ipCustomization = nil
            return
        }
        
        current.ipCustomization = userData.ipCustomizations
            .first(where: {$0.ipAddress == network.publicIp!.ipAddress})
    }
    
    private func reactivateIpApis() {
        for index in 0..<userData.ipApis.count {
            if !userData.ipApis[index].isActive() {
                userData.ipApis[index].active = true
            }
        }
    }
}

extension AppState {
    struct Current : Equatable {
        var ipCustomization: IpCustomization? = nil
        var colorScheme: ColorScheme = .light
        
        static func == (lhs: Current, rhs: Current) -> Bool {
            let result = lhs.ipCustomization == rhs.ipCustomization
            
            return result
        }
    }
}

extension AppState {
    struct Network : Equatable {
        var status: NetworkStatusType = NetworkStatusType.unknown
        var publicIp: IpInfo? = nil
        var localIp: String? = nil
        var isObtainingIp = false
        var hasInternetAccess = true
        var activeNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
        
        func isConnectionChanged (
            status: NetworkStatusType,
            activeNetworkInterfaces: [NetworkInterface]) -> Bool {
                let result = self.status != status || self.activeNetworkInterfaces != activeNetworkInterfaces
                return result
        }
        
        static func == (lhs: Network, rhs: Network) -> Bool {
            let result = lhs.status == rhs.status
            && lhs.publicIp == rhs.publicIp
            && lhs.isObtainingIp == rhs.isObtainingIp
            && lhs.hasInternetAccess == rhs.hasInternetAccess
            && lhs.activeNetworkInterfaces == rhs.activeNetworkInterfaces
            
            return result
        }
    }
}

extension AppState {
    struct Views {
        var shownWindows: [String]
    }
}

extension AppState {
    struct UserData : Settable, Equatable {
        var internetCheckUrl: String = Constants.defaultInternetCheckUrl {
            didSet { writeSetting(newValue: internetCheckUrl, key: Constants.settingsKeyInternetCheckUrl) }
        }
        var menuBarShownItems = Constants.defaultShownMenuBarItems {
            didSet { writeSettingsArray(newValues: menuBarShownItems, key: Constants.settingsKeyShownMenuBarItems) }
        }
        var menuBarHiddenItems = Constants.defaultHiddenMenuBarItems {
            didSet { writeSettingsArray(newValues: menuBarHiddenItems, key: Constants.settingsKeyHiddenMenuBarItems) }
        }
        var menuBarTextSize: Double = Constants.defaultMenuBarTextSize {
            didSet { writeSetting(newValue: menuBarTextSize, key: Constants.settingsKeyMenuBarTextSize) }
        }
        var menuBarSpacing: Double = Constants.defaultMenuBarSpacing {
            didSet { writeSetting(newValue: menuBarSpacing, key: Constants.settingsElementSpacing) }
        }
        var menuBarUseThemeColor: Bool = false {
            didSet { writeSetting(newValue: menuBarUseThemeColor, key: Constants.settingsKeyMenuBarUseThemeColor) }
        }
        var ipCustomizations = [IpCustomization]() {
            didSet { writeSettingsArray(newValues: ipCustomizations, key: Constants.settingsKeyIpCustomizations) }
        }
        var ipApis = [IpApiInfo]() {
            didSet { writeSettingsArray(newValues: ipApis, key: Constants.settingsKeyApis) }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
            internetCheckUrl = readSetting(key: Constants.settingsKeyInternetCheckUrl) ?? Constants.defaultInternetCheckUrl
            menuBarUseThemeColor = readSetting(key: Constants.settingsKeyMenuBarUseThemeColor) ?? false
            menuBarTextSize = readSetting(key: Constants.settingsKeyMenuBarTextSize) ?? Constants.defaultMenuBarTextSize
            menuBarSpacing = readSetting(key: Constants.settingsKeyMenuBarSpacing) ?? Constants.defaultMenuBarSpacing
            
            let savedIps: [IpCustomization]? = readSettingsArray(key: Constants.settingsKeyIpCustomizations)
            let savedIpApis: [IpApiInfo]? = readSettingsArray(key: Constants.settingsKeyApis)
            let savedMenuBarShownItems: [String]? = readSettingsArray(key: Constants.settingsKeyShownMenuBarItems)
            let savedMenuBarHiddenItems: [String]? = readSettingsArray(key: Constants.settingsKeyHiddenMenuBarItems)
            
            if (savedIps != nil) {
                ipCustomizations = savedIps!
            }
            
            if (savedIpApis == nil) {
                for ipApiUrl in Constants.ipApiUrls {
                    let apiInfo = IpApiInfo(url: ipApiUrl, active: true)
                    ipApis.append(apiInfo)
                }
            }
            else {
                ipApis = savedIpApis!
            }
            
            if (savedMenuBarShownItems != nil) {
                menuBarShownItems = savedMenuBarShownItems!
            }
            
            if (savedMenuBarHiddenItems != nil) {
                menuBarHiddenItems = savedMenuBarHiddenItems!
            }
        }
    }
}
