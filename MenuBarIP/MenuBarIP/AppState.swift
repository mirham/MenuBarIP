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
        var currentIpInfo: IpInfoBase? = nil
        var obtainingIp = false
        var activeNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
    }
}

extension AppState {
    struct Views {
        var isSettingsViewShown = false
        var isInfoViewShown = false
    }
}

extension AppState {
    struct UserData : Settable, Equatable {
        var ips = [IpInfo]() {
            didSet { writeSettingsArray(newValues: ips, key: Constants.settingsKeyIps) }
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
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
            let savedIps: [IpInfo]? = readSettingsArray(key: Constants.settingsKeyIps)
            let savedIpApis: [IpApiInfo]? = readSettingsArray(key: Constants.settingsKeyApis)
            let savedMenuBarShownItems: [String]? = readSettingsArray(key: Constants.settingsKeyShownMenuBarItems)
            let savedMenuBarHiddenItems: [String]? = readSettingsArray(key: Constants.settingsKeyHiddenMenuBarItems)
            
            if (savedIps != nil) {
                ips = savedIps!
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
