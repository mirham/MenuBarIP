//
//  Constants.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct Constants{
    // MARK: Default values
    static let defaultCountryCode = "US"
    static let defaultPublicIpAddress = "1.1.1.1"
    static let defaultLocalIpAddress = "192.168.1.2"
    static let zshPath = "/bin/zsh"
    static let launchAgentName = "\(Bundle.main.bundleIdentifier!)"
    static let launchAgentPlistName = "\(Bundle.main.bundleIdentifier!).plist"
    static let launchAgents = "LaunchAgents"
    static let launchAgentsFolderPath = "~/Library/LaunchAgents/"
    static let networkMonitorQueryLabel = "MBIPNetworkMonitor"
    static let ipV4: Int = 4
    static let ipV6: Int = 6
    static let defaultToleranceInNanoseconds: UInt64 = 100_000_000
    static let menuBarItemTimeToleranceInSeconds: Int = 1
    static let physicalNetworkInterfacePrefix = "en"
    static let defaultMenuBarTextSize: Double = 10.0
    static let defaultMenuBarSpacing: Double = 4.0
    static let maxCustomTextSymbols: Int = 20
    static let defaultCheckConnectionHealthInterval: Int = 5
    static let defaultLightColor = "#FEFFFF"
    static let defaultDarkColor = "#000001"
    static let defaultInternetCheckUrl = "https://google.com"
    
    // MARK: Regexes
    static let regexUrl = /(?<protocol>https?):\/\/(?:(?<username>[^:@\s\/\\]*)(?::(?<password>[^:@\s\/\\]*))?@)?(?<domain>[\w\d]+[\w\d.\-]+[\w\d]+|\[[a-f\d:]+\])(?::(?<port>\d+))?(?:(?<path>\/[^\?#\s]*)(?:\?(?<query>[^\?#\s]*))?(?:#(?<anchor>[^\?#\s]*))?)?/
    
    // MARK: Icons
    static let iconApp = "AppIcon"
    static let iconCheckmark = "checkmark.circle.fill"
    static let iconCircle = "circle"
    static let iconQuestionMark = "questionmark.circle.fill"
    static let iconSettings = "gearshape.2"
    static let iconInfo = "info.circle.fill"
    static let iconQuit = "xmark.circle"
    static let iconObtaining = "network"
    static let iconNotConnected = "network.slash"
    static let iconIpPoint = "ippoint"
    static let iconEdit = "pencil.line"
    static let iconSave = "chevron.down"
    
    // MARK: Symbols
    static let bullet = "•"
    static let pipe = "|"
    static let leftBracket = "("
    static let rightBracket = ")"
    
    // MARK: Window IDs
    static let windowIdSettings = "settings-view"
    static let windowIdPublicIpLocation = "public-ip-location-view"
    static let windowIdInfo = "info-view"
    
    // MARK:  Settings key names
    static let settingsKeyIpCustomizations = "ip-customizations"
    static let settingsKeyApis = "apis"
    static let settingsKeyShownMenuBarItems = "shown-menubar-items"
    static let settingsKeyHiddenMenuBarItems = "hidden-menubar-items"
    static let settingsKeyMenuBarUseThemeColor = "menubar-use-theme-color"
    static let settingsKeyMenuBarTextSize = "menubar-text-size"
    static let settingsKeyMenuBarSpacing = "menubar-spacing"
    static let settingsKeyInternetCheckUrl = "internet-check-url"
    
    // MARK: Elements names
    static let info = "Info"
    static let save = "Save"
    static let none = "..."
    static let add = "Add"
    static let edit = "Edit"
    static let delete = "Delete"
    static let ok = "OK"
    static let ip = "IP"
    static let apiUrl = "API address"
    static let internetCheckUrl = "Check if internet access using address"
    static let customText = "Custom text"
    static let light = "Light"
    static let dark = "Dark"
    static let publicIp = "Public IP"
    static let localIp = "Local IP"
    static let obtainingIp = "Obtaining IP..."
    static let offline = "Offline"
    static let noInternet = "No internet"
    
    // MARK: Settings elements names
    static let settingsElementGeneral = "General"
    static let settingsElementMenubar = "Menu bar"
    static let settingsElementCustomization = "Customization"
    static let settingsElementShownItems = "Shown menu bar items"
    static let settingsElementHiddenItems = "Hidden menu bar items"
    static let settingsElementItemsSize = "Items size"
    static let settingsElementSpacing = "Spacing"
    static let settingsElementKeepAppRunning = "Keep application running"
    static let settingsElementIps = "IP adresses customization"
    static let settingsElementIpAddressApis = "IP APIs"
    static let settingsElementThemeColor = "Use system theme color"
    
    // MARK: Dialogs
    static let dialogHeaderIpAddressIsNotValid = "IP Address is not valid"
    static let dialogBodyIpAddressIsNotValid = "IP Address seems to not be valid and cannot be added."
    static let dialogHeaderApiIsNotValid = "API for getting IP Address is not valid"
    static let dialogBodyApiIsNotValid = "API doesn't return a valid IP address as a plain text and cannot be added."
    static let dialogHeaderUrlIsNotValid = "Address for checking Internet access is not applicable"
    static let dialogBodyUrlIsNotValid = "The address for checking Internet access does not return correct data and cannot be used."
    
    // MARK: Hints
    static let hintApiIsActive = "API is active and in use"
    static let hintApiIsInactive = "API is not active and not in use"
    static let hintNewVaildIpAddress = "A new valid IP address"
    static let hintNewCustomText = "A new custom text"
    static let hintNewVaildUrl = "A new valid URL"
    static let hintNewVaildApiUrl = "A new valid API URL"
    static let hintLightColor = "Light theme color"
    static let hintDarkColor = "Dark theme color"
    static let hintKeepApplicationRunning = "The application will be opened after the system starts or if it was closed."
    static let hintMenuBarAdjustment = "Drag menu bar item icons between the sections below to arrange item as you want"
    static let hintIps = "Add an IP address customization with desired custom text and custom color for light and dark theme\nRight click on the customization to display the context menu"
    static let hintIpApis = "Add an API that returns the public IP address in plain text\nRight click on the API to display the context menu\nIf API marked green, it works properly and in use"
    
    // MARK: Menubar item keys
    static let mbItemKeyPublicIpAddress = "public-ip-address"
    static let mbItemKeyPublicIpAddressWithCustomText = "public-ip-address-with-custom-text"
    static let mbItemKeyLocalIpAddress = "local-ip-address"
    static let mbItemKeyBothIpAddressesPublicUpper = "both-ips-public-upper"
    static let mbItemKeyCountryCode = "country-code"
    static let mbItemKeyCountryFlag = "country-flag"
    static let mbItemKeyInternetStatus = "internet-status"
    static let mbItemKeyBigCountryFlag = "big-country-flag"
    static let mbItemKeyCustomText = "custom-text"
    static let mbItemKeySeparatorBullet = "separator-bullet"
    static let mbItemKeySeparatorBigBullet = "separator-big-bullet"
    static let mbItemKeySeparatorPipe = "separator-pipe"
    static let mbItemKeySeparatorLeftBracket = "separator-left-bracket"
    static let mbItemKeySeparatorRightBracket = "separator-right-bracket"
    
    // MARK: Window titles
    static let wnidowTitlePublicIplocation = "Public IP location"
    
    // MARK: Menu items
    static let menuItemCopy = "Copy"
    static let menuItemShowOnMap = "Show on map"
    static let menuItemSettings = "Settings"
    static let menuItemRefresh = "Refresh"
    static let menuItemAbout = "About"
    static let menuItemQuit = "Quit"
    
    // MARK: Error messages
    static let errorNoActiveIpApiFound = "Not possible to obtain IP, try to add a new IP API in the Settings to proceed work or check DNS availability"
    static let errorWhenCallingIpAddressApi = "Error when called IP address API '%1$@': '%2$@', API marked as inactive and will be skipped until next application run"
    static let errorIpApiResponseIsInvalid = "IP address API returned invalid IP address"
    static let errorWhenCallingIpInfoApi = "Error when called IP info API: %1$@"
    
    // MARK: Shell commands
    static let shCommandLoadLaunchAgent = "launchctl load %1$@%2$@"
    static let shCommandEnableLaunchAgent = "launchctl enable %1$@"
    static let shCommandRemoveLaunchAgent = "launchctl remove %1$@"
    
    // MARK: About
    static let aboutSupportMail = "bWlyaGFtQGFidi5iZw=="
    static let aboutGitHubLink = "https://github.com/mirham/MenuBarIP"
    
    static let aboutBackground = "AppInfo"
    
    static let aboutVersionKey = "CFBundleShortVersionString"
    static let aboutGetSupport = "Get support:"
    static let aboutVersion = "Version: %1$@"
    static let aboutMailTo = "mailto:%1$@"
    static let aboutGitHub = "GitHub"
    
    // MARK: Static data
    static let ipApiUrls = [
        "http://api.ipify.org",
        "http://icanhazip.com",
        "http://ipinfo.io/ip",
        "http://ipecho.net/plain",
        "https://checkip.amazonaws.com",
        "http://whatismyip.akamai.com",
        "https://api.seeip.org",
        "https://ipapi.co/ip"
    ]
    
    static let launchAgentXmlContent =
        """
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(Bundle.main.bundleIdentifier!)</string>
                <key>KeepAlive</key>
                <true/>
                <key>Program</key>
                <string>%1$@</string>
            </dict>
        </plist>
        """;
    
    static let defaultShownMenuBarItems = [
        mbItemKeyPublicIpAddress,
        mbItemKeySeparatorBullet,
        mbItemKeyCountryFlag,
        mbItemKeyCountryCode
    ]
    
    static let defaultHiddenMenuBarItems = [
        mbItemKeyInternetStatus,
        mbItemKeyBigCountryFlag,
        mbItemKeyPublicIpAddressWithCustomText,
        mbItemKeyBothIpAddressesPublicUpper,
        mbItemKeyLocalIpAddress,
        mbItemKeyCustomText,
        mbItemKeySeparatorBullet,
        mbItemKeySeparatorBigBullet,
        mbItemKeySeparatorPipe,
        mbItemKeySeparatorLeftBracket,
        mbItemKeySeparatorRightBracket
    ]
}
