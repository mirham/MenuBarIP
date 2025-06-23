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
        var prevPublicIp: IpInfo? = nil
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
            && lhs.publicIp?.hasLocation() == rhs.publicIp?.hasLocation()
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
        var enableLogging: Bool = false {
            didSet { writeSetting(newValue: enableLogging, key: Constants.settingsKeyEnableLogging) }
        }
        var logFileLimit: Int = Constants.defaultLogFileLimit {
            didSet { writeSetting(newValue: logFileLimit, key: Constants.settingsKeyLogFileLimit) }
        }
        var runScript: Bool = false {
            didSet { writeSetting(newValue: runScript, key: Constants.settingsKeyRunScript) }
        }
        var scriptPath: String = String() {
            didSet { writeSetting(newValue: scriptPath, key: Constants.settingsKeyScriptPath) }
        }
        var internetCheckUrl1: String = Constants.defaultInternetCheckUrl1 {
            didSet { writeSetting(newValue: internetCheckUrl1, key: Constants.settingsKeyInternetCheckUrl1) }
        }
        var internetCheckUrl2: String = Constants.defaultInternetCheckUrl2 {
            didSet { writeSetting(newValue: internetCheckUrl2, key: Constants.settingsKeyInternetCheckUrl2) }
        }
        var internetCheckUrl3: String = Constants.defaultInternetCheckUrl3 {
            didSet { writeSetting(newValue: internetCheckUrl3, key: Constants.settingsKeyInternetCheckUrl3) }
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
        var ipInfoApiUrl: String = Constants.defaultIpInfoApiUrl {
            didSet { writeSetting(newValue: ipInfoApiUrl, key: Constants.settingsKeyIpInfoApiUrl) }
        }
        var ipInfoApiKeyMapping: [String:String] = Constants.defaultIpInfoApiKeyMapping {
            didSet { writeSettingsDictionary(newValues: ipInfoApiKeyMapping, key: Constants.settingsKeyIpInfoMapping) }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
            enableLogging = readSetting(key: Constants.settingsKeyEnableLogging) ?? false
            logFileLimit = readSetting(key: Constants.settingsKeyLogFileLimit) ?? Constants.defaultLogFileLimit
            runScript = readSetting(key: Constants.settingsKeyRunScript) ?? false
            scriptPath = readSetting(key: Constants.settingsKeyScriptPath) ?? String()
            internetCheckUrl1 = readSetting(key: Constants.settingsKeyInternetCheckUrl1) ?? Constants.defaultInternetCheckUrl1
            internetCheckUrl2 = readSetting(key: Constants.settingsKeyInternetCheckUrl2) ?? Constants.defaultInternetCheckUrl2
            internetCheckUrl3 = readSetting(key: Constants.settingsKeyInternetCheckUrl3) ?? Constants.defaultInternetCheckUrl3
            menuBarUseThemeColor = readSetting(key: Constants.settingsKeyMenuBarUseThemeColor) ?? false
            menuBarTextSize = readSetting(key: Constants.settingsKeyMenuBarTextSize) ?? Constants.defaultMenuBarTextSize
            menuBarSpacing = readSetting(key: Constants.settingsKeyMenuBarSpacing) ?? Constants.defaultMenuBarSpacing
            ipInfoApiUrl = readSetting(key: Constants.settingsKeyIpInfoApiUrl) ?? Constants.defaultIpInfoApiUrl
            
            if let savedIps:[IpCustomization] = readSettingsArray(key: Constants.settingsKeyIpCustomizations) {
                ipCustomizations = savedIps
            }
            
            if let savedIpApis:[IpApiInfo] = readSettingsArray(key: Constants.settingsKeyApis) {
                ipApis = savedIpApis
            } else {
                for ipApiUrl in Constants.ipApiUrls {
                    let apiInfo = IpApiInfo(url: ipApiUrl, active: true)
                    ipApis.append(apiInfo)
                }
            }
            
            if let savedMenuBarShownItems: [String] = readSettingsArray(key: Constants.settingsKeyShownMenuBarItems) {
                menuBarShownItems = savedMenuBarShownItems
            }
            
            if let savedMenuBarHiddenItems: [String] = readSettingsArray(key: Constants.settingsKeyHiddenMenuBarItems) {
                menuBarHiddenItems = savedMenuBarHiddenItems
            }
            
            if let savedIpInfoApiMapping: [String:String] = readSettingsDictionary(key: Constants.settingsKeyIpInfoMapping) {
                ipInfoApiKeyMapping = savedIpInfoApiMapping
            }
        }
        
        func hasActiveIpApi() -> Bool {
            return !ipApis.isEmpty && ipApis.contains(where: {$0.isActive()})
        }
    }
}
