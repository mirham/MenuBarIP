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
        var areIpApisReactivated = false
        var updatedNetwork = Network()
        
        if update.hasInternetAccess == nil {
            updatedNetwork.hasInternetAccess = network.hasInternetAccess
        }
        else {
            updatedNetwork.hasInternetAccess = update.hasInternetAccess!
            
            userData.reactivateIpApis()
            areIpApisReactivated = true
        }
        
        if update.status == nil {
            updatedNetwork.status = network.status
        }
        else {
            updatedNetwork.status = update.status!
            let apiReactivationNeeded = network.status != .on && update.status == .on && !areIpApisReactivated
            
            if apiReactivationNeeded {
                userData.reactivateIpApis()
            }
        }
        
        updatedNetwork.isObtainingIp = update.isObtainingIp ?? network.isObtainingIp
        updatedNetwork.publicIp = update.forceUpdatePublicIp ? update.publicIp : network.publicIp
        updatedNetwork.localIp = update.localIp ?? network.localIp
        updatedNetwork.activeNetworkInterfaces = update.activeNetworkInterfaces ?? network.activeNetworkInterfaces
        
        if network != updatedNetwork {
            network = updatedNetwork
        }
    }
    
    // MARK: Private functions
    
    private func setCurrentState() {
        setLocalIpCustomization()
        setPublicIpCustomization()
        setCustomTextCustomization()
    }
    
    private func setLocalIpCustomization() {
        guard let localIp = network.localIp else {
            current.localIpCustomization = nil
            return
        }
        
        current.localIpCustomization = userData.ipCustomizations
            .first { $0.value == localIp }
    }
    
    private func setPublicIpCustomization() {
        guard let publicIp = network.publicIp?.ipAddress else {
            current.ipCustomization = nil
            return
        }
        
        let customization = userData.ipCustomizations
            .first { $0.value == publicIp }
        
        guard let customization = customization
        else { return }
        
        current.ipCustomization = customization
        current.publicIpCustomText = customization.customText
    }
    
    private func setCustomTextCustomization() {
        guard let publicIp = network.publicIp else {
            current.customTextCustomization = nil
            current.publicIpCustomText = nil
            return
        }
        
        guard current.ipCustomization == nil
        else { return }
        
        findAndApplyCustomTextCustomization(for: publicIp)
    }
    
    private func findAndApplyCustomTextCustomization(for ipInfo: IpInfo) {
        var bestMatch: (customization: Customization, matchedValue: String)?
        var fallbackMatch: (customization: Customization, matchedValue: String)?
        
        for customization in userData.customTextCustomizations {
            guard let matchedValue = customization.getIpInfoMatch(ipInfo: ipInfo)
            else { continue }
            
            if !customization.customText.isEmpty {
                bestMatch = (customization, matchedValue)
                break
            } else if fallbackMatch == nil {
                fallbackMatch = (customization, matchedValue)
            }
        }
        
        applyTextCustomization(bestMatch ?? fallbackMatch)
    }
    
    private func applyTextCustomization(_ match: (
        customization: Customization,
        matchedValue: String)?) {
        current.customTextCustomization = match?.customization
        current.publicIpCustomText = match?.matchedValue
    }
}

extension AppState {
    struct Current : Equatable {
        var refreshSignal: Bool = false
        var ipCustomization: Customization? = nil
        var localIpCustomization: Customization? = nil
        var customTextCustomization: Customization? = nil
        var publicIpCustomText: String? = nil
        var colorScheme: ColorScheme = .light
        
        static func == (lhs: Current, rhs: Current) -> Bool {
            let result = lhs.ipCustomization == rhs.ipCustomization
            && lhs.localIpCustomization == rhs.localIpCustomization
            && lhs.customTextCustomization == rhs.customTextCustomization
            
            return result
        }
    }
}

extension AppState {
    struct Network : Equatable {
        var refreshSignal: Bool = false
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
        var periodicIpCheck: Bool = false {
            didSet {
                writeSetting(
                    newValue: periodicIpCheck,
                    key: Constants.settingsKeyPeriodicIpCheck)
            }
        }
        var intervalBetweenChecks: Int = Constants.defaultIntervalBetweenChecksSeconds {
            didSet {
                writeSetting(
                    newValue: intervalBetweenChecks,
                    key: Constants.settingsKeyIntervalBetweenChecks)
            }
        }
        var enableLogging: Bool = false {
            didSet {
                writeSetting(
                    newValue: enableLogging,
                    key: Constants.settingsKeyEnableLogging)
            }
        }
        var logFileLimit: Int = Constants.defaultLogFileLimit {
            didSet {
                writeSetting(
                    newValue: logFileLimit,
                    key: Constants.settingsKeyLogFileLimit)
            }
        }
        var runScript: Bool = false {
            didSet {
                writeSetting(
                    newValue: runScript,
                    key: Constants.settingsKeyRunScript)
            }
        }
        var scriptPath: String = String() {
            didSet {
                writeSetting(
                    newValue: scriptPath,
                    key: Constants.settingsKeyScriptPath)
            }
        }
        var internetCheckUrl1: String = Constants.defaultInternetCheckUrl1 {
            didSet {
                writeSetting(
                    newValue: internetCheckUrl1,
                    key: Constants.settingsKeyInternetCheckUrl1)
            }
        }
        var internetCheckUrl2: String = Constants.defaultInternetCheckUrl2 {
            didSet {
                writeSetting(
                    newValue: internetCheckUrl2,
                    key: Constants.settingsKeyInternetCheckUrl2)
            }
        }
        var internetCheckUrl3: String = Constants.defaultInternetCheckUrl3 {
            didSet {
                writeSetting(
                    newValue: internetCheckUrl3,
                    key: Constants.settingsKeyInternetCheckUrl3)
            }
        }
        var menuBarShownItems = Constants.defaultShownMenuBarItems {
            didSet {
                writeSettingsArray(
                    newValues: menuBarShownItems,
                    key: Constants.settingsKeyShownMenuBarItems)
            }
        }
        var menuBarHiddenItems = Constants.defaultHiddenMenuBarItems {
            didSet {
                writeSettingsArray(
                    newValues: menuBarHiddenItems,
                    key: Constants.settingsKeyHiddenMenuBarItems)
            }
        }
        var menuBarTextSize: Double = Constants.defaultMenuBarTextSize {
            didSet {
                writeSetting(
                    newValue: menuBarTextSize,
                    key: Constants.settingsKeyMenuBarTextSize)
            }
        }
        var menuBarSpacing: Double = Constants.defaultMenuBarSpacing {
            didSet {
                writeSetting(
                    newValue: menuBarSpacing,
                    key: Constants.settingsElementSpacing)
            }
        }
        var menuBarUseThemeColor: Bool = false {
            didSet {
                writeSetting(
                    newValue: menuBarUseThemeColor,
                    key: Constants.settingsKeyMenuBarUseThemeColor)
            }
        }
        var ipCustomizations = [Customization]() {
            didSet {
                writeSettingsArray(
                    newValues: ipCustomizations,
                    key: Constants.settingsKeyIpCustomizations)
            }
        }
        var customTextCustomizations = [Customization]() {
            didSet {
                writeSettingsArray(
                    newValues: customTextCustomizations,
                    key: Constants.settingsKeyCustomTextCustomizations)
            }
        }
        var ipApis = [IpApiInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: ipApis,
                    key: Constants.settingsKeyApis)
            }
        }
        var ipInfoApiUrl: String = Constants.defaultIpInfoApiUrl {
            didSet {
                writeSetting(
                    newValue: ipInfoApiUrl,
                    key: Constants.settingsKeyIpInfoApiUrl)
            }
        }
        var ipInfoApiKeyMapping: [String:String] = Constants.defaultIpInfoApiKeyMapping {
            didSet {
                writeSettingsDictionary(
                    newValues: ipInfoApiKeyMapping,
                    key: Constants.settingsKeyIpInfoMapping)
            }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
            periodicIpCheck = readSetting(key: Constants.settingsKeyPeriodicIpCheck) ?? false
            intervalBetweenChecks = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? Constants.defaultIntervalBetweenChecksSeconds
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
            
            if let savedIpCustomizations:[Customization] = readSettingsArray(key: Constants.settingsKeyIpCustomizations) {
                ipCustomizations = savedIpCustomizations
            }
            
            if let savedCustomTextCustomizations:[Customization] = readSettingsArray(key: Constants.settingsKeyCustomTextCustomizations) {
                customTextCustomizations = savedCustomTextCustomizations
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
                    .syncWithDefaults(
                        Array(Set(Constants.defaultShownMenuBarItems + Constants.defaultHiddenMenuBarItems)),
                        excluding: menuBarShownItems)
            }
            
            if let savedIpInfoApiMapping: [String:String] = readSettingsDictionary(key: Constants.settingsKeyIpInfoMapping) {
                ipInfoApiKeyMapping = savedIpInfoApiMapping
                    .mergingMissingPairs(from: Constants.defaultIpInfoApiKeyMapping)
            }
        }
        
        func hasActiveIpApi() -> Bool {
            return !ipApis.isEmpty && ipApis.contains(where: {$0.isActive()})
        }
        
        mutating func reactivateIpApis() {
            for index in 0..<ipApis.count {
                if !ipApis[index].isActive() {
                    ipApis[index].active = true
                }
            }
        }
    }
}
