//
//  AppState.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

class AppState : ObservableObject {
    @Published var network = Network()
    @Published var views = Views()
    @Published var userData = UserData()
    
    static let shared = AppState()
}

extension AppState {
    struct Network : Equatable {
        var status: NetworkStatusType = NetworkStatusType.unknown
        var publicIpInfo: IpInfo? = nil
        var localIp: String? = nil
        var obtainingIp = false
        var activeNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
    }
}

extension AppState {
    struct Views {
        var isSettingsViewShown = false
        var isPublicIpLocationViewShown = false
        var isInfoViewShown = false
    }
}

extension AppState {
    struct UserData : Settable, Equatable {
        var ipCustomizations = [IpCustomization]() {
            didSet { writeSettingsArray(newValues: ipCustomizations, key: Constants.settingsKeyIpCustomizations) }
        }
        var ipApis = [IpApiInfo]() {
            didSet { writeSettingsArray(newValues: ipApis, key: Constants.settingsKeyApis) }
        }
        var menuBarShownItems = Constants.defaultShownMenuBarItems {
            didSet { writeSettingsArray(newValues: menuBarShownItems, key: Constants.settingsKeyShownMenuBarItems) }
        }
        var menuBarHiddenItems = Constants.defaultHiddenMenuBarItems {
            didSet { writeSettingsArray(newValues: menuBarHiddenItems, key: Constants.settingsKeyHiddenMenuBarItems) }
        }
        var menuBarUseThemeColor: Bool = false {
            didSet { writeSetting(newValue: menuBarUseThemeColor, key: Constants.settingsKeyMenuBarUseThemeColor) }
        }
        var menuBarTextSize: Double = Constants.defaultMenuBarTextSize {
            didSet { writeSetting(newValue: menuBarTextSize, key: Constants.settingsKeyMenuBarTextSize) }
        }
        var menuBarSpacing: Double = Constants.defaultMenuBarSpacing {
            didSet { writeSetting(newValue: menuBarSpacing, key: Constants.settingsElementSpacing) }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
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
