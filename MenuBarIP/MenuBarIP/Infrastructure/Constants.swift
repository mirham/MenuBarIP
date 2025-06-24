//
//  Constants.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

struct Constants{
    // MARK: Default values
    static let defaultAppBundleName = "com.mirham.MenuBarIP"
    static let defaultCountryCode = "US"
    static let defaultPublicIpAddress = "1.1.1.1"
    static let defaultLocalIpAddress = "192.168.1.2"
    static let fileExtApp = "app"
    static let fileExtSh = "sh"
    static let fileExtPy = "py"
    static let fileExtRb = "rb"
    static let fileExtPl = "pl"
    static let fileExtPhp = "php"
    static let fileExtScpt = "scpt"
    static let fileExtJs = "js"
    static let fileExtTxt = "txt"
    static let pathZsh = "/bin/zsh"
    static let pathEnv = "/usr/bin/env "
    static let pathPython = "\(pathEnv) python3"
    static let pathRuby = "\(pathEnv) ruby"
    static let pathPerl = "\(pathEnv) perl"
    static let pathPhp = "\(pathEnv) php"
    static let pathAppleScript = "/usr/bin/osascript"
    static let pathJs = "\(pathEnv) node"
    static let headHttpMethod = "HEAD"
    static let launchAgentName = "\(Bundle.main.bundleIdentifier!)"
    static let launchAgentPlistName = "\(Bundle.main.bundleIdentifier!).plist"
    static let logFileName = "public_ip.log"
    static let loggerQueueLabel = "\(Bundle.main.bundleIdentifier!).logger"
    static let scriptingQueueLabel = "\(Bundle.main.bundleIdentifier!).scripting"
    static let launchAgents = "LaunchAgents"
    static let launchAgentsFolderPath = "~/Library/LaunchAgents/"
    static let networkMonitorQueryLabel = "MBIPNetworkMonitor"
    static let ipV4: Int = 4
    static let ipV6: Int = 6
    static let defaultToleranceInNanoseconds: UInt64 = 100_000_000
    static let menuBarItemTimeToleranceInSeconds: Int = 1
    static let callTimeoutIpApiInSeconds: Double = 1.0
    static let callTimeoutIpApiTotalInSeconds: Double = 20.0
    static let callTimeoutIpInfoApiInSeconds: Double = 2.0
    static let callTimeoutSiteInSeconds: Double = 5.0
    static let physicalNetworkInterfacePrefix = "en"
    static let defaultMenuBarTextSize: Double = 10.0
    static let defaultMenuBarSpacing: Double = 4.0
    static let maxCustomTextSymbols: Int = 20
    static let defaultCheckConnectionHealthIntervalSeconds: Int = 5
    static let defaultCheckConnectionHealthIntervalNanoseconds: UInt64 = UInt64(defaultCheckConnectionHealthIntervalSeconds * 1_000_000_000)
    static let defaultLightColor = "#FEFFFF"
    static let defaultDarkColor = "#000001"
    static let defaultInternetCheckUrl1 = "https://google.com"
    static let defaultInternetCheckUrl2 = "https://duckduckgo.com"
    static let defaultInternetCheckUrl3 = "https://www.yahoo.com"
    static let defaultIpInfoApiUrl = "http://ip-api.com/json/\(publicIpMask)"
    static let defaultLogFileLimit: Int = 1000
    static let minLogFileLimit: Int = 10
    static let maxLogFileLimit: Int = 10000
    static let newLine: String = "\n"
    static let loggerDomainName = "Logger"
    static let levelDebug = "Debug"
    static let levelInfo = "Info"
    static let levelError = "Error"
    static let minIpApiCount: Int = 1
    static let envPathName = "PATH"
    static let envPossiblePathes = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    static let space = " "
    static let slash = "/"
    static let scriptContentPrefix = "#!"
    
    // MARK: Regexes
    static let regexUrl = /(?<protocol>https?):\/\/(?:(?<username>[^:@\s\/\\]*)(?::(?<password>[^:@\s\/\\]*))?@)?(?<domain>[\w\d]+[\w\d.\-]+[\w\d]+|\[[a-f\d:]+\])(?::(?<port>\d+))?(?:(?<path>\/[^\?#\s]*)(?:\?(?<query>[^\?#\s]*))?(?:#(?<anchor>[^\?#\s]*))?)?/
    
    // MARK: Masks
    static let logEntryDateTimeMask = "yyyy-MM-dd @ HH:mm:ss"
    static let logConsoleMessageMask: StaticString = "%{public}s"
    static let publicIpMask = "%IP%"
    
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
    static let iconNoActiveIpApi = "exclamationmark.triangle.fill"
    static let iconIpPoint = "ippoint"
    static let iconEdit = "pencil.line"
    static let iconSave = "chevron.down"
    static let iconArrowBackward = "arrow.backward"
    
    // MARK: Symbols
    static let bullet = "•"
    static let pipe = "|"
    static let leftBracket = "("
    static let rightBracket = ")"
    
    // MARK: Window IDs
    static let windowIdSettings = "settings-view"
    static let windowIdPublicIpLocation = "public-ip-location-view"
    static let windowIdLog = "log-view"
    static let windowIdInfo = "info-view"
    
    // MARK:  Settings key names
    static let settingsKeyEnableLogging = "enable-logging"
    static let settingsKeyLogFileLimit = "log-file-limit"
    static let settingsKeyRunScript = "run-script"
    static let settingsKeyScriptPath = "script-path"
    static let settingsKeyIpCustomizations = "ip-customizations"
    static let settingsKeyApis = "apis"
    static let settingsKeyShownMenuBarItems = "shown-menubar-items"
    static let settingsKeyHiddenMenuBarItems = "hidden-menubar-items"
    static let settingsKeyMenuBarUseThemeColor = "menubar-use-theme-color"
    static let settingsKeyMenuBarTextSize = "menubar-text-size"
    static let settingsKeyMenuBarSpacing = "menubar-spacing"
    static let settingsKeyInternetCheckUrl1 = "internet-check-url-1"
    static let settingsKeyInternetCheckUrl2 = "internet-check-url-2"
    static let settingsKeyInternetCheckUrl3 = "internet-check-url-3"
    static let settingsKeyIpInfoApiUrl = "ip-info-api-url"
    static let settingsKeyIpInfoMapping = "ip-info-api-matches"
    
    // MARK: Elements names
    static let info = "Info"
    static let save = "Save"
    static let none = "..."
    static let add = "Add"
    static let edit = "Edit"
    static let delete = "Delete"
    static let copy = "Copy"
    static let ok = "OK"
    static let ip = "IP"
    static let apiUrl = "API address"
    static let internetCheckUrl = "Check if internet access using addresses"
    static let ipInfoApiUrl = "IP info API address (use \(publicIpMask) for public IP address)"
    static let customText = "Custom text"
    static let light = "Light"
    static let dark = "Dark"
    static let publicIp = "Public IP"
    static let localIp = "Local IP"
    static let obtainingIp = "Obtaining IP..."
    static let offline = "Offline"
    static let noInternet = "No internet"
    static let checked = "Checked"
    static let unchecked = "Unchecked"
    static let clearLog = "Clear"
    static let showLogInFolder = "Show in folder"
    static let choose = "Choose"
    static let mappings = "Mappings"
    static let noActiveIpApi = "No active IP API"
    
    // MARK: Settings elements names
    static let settingsElementGeneral = "General"
    static let settingsElementMenubar = "Menu bar"
    static let settingsElementKeepAppRunning = "Keep application running"
    static let settingsElementEnableLogging = "Enable public IP address logging"
    static let settingsElementRunScript = "Run application or script when public IP address changes"
    static let settingsElementLogFileLimit = "Log file lines limit"
    static let settingsElementCustomization = "Customization"
    static let settingsElementShownItems = "Shown menu bar items"
    static let settingsElementHiddenItems = "Hidden menu bar items"
    static let settingsElementItemsSize = "Items size"
    static let settingsElementSpacing = "Spacing"
    static let settingsElementIps = "IP adresses customization"
    static let settingsElementIpAddressApis = "IP APIs"
    static let settingsElementThemeColor = "Use system theme color"
    static let settingsElementIpInfoApi = "IP info API"
    
    // MARK: Dialogs
    static let dialogHeaderIpAddressIsNotValid = "IP Address is not valid"
    static let dialogBodyIpAddressIsNotValid = "IP Address seems to not be valid and cannot be added."
    static let dialogHeaderApiIsNotValid = "API for getting IP address is not valid"
    static let dialogBodyApiIsNotValid = "API doesn't return a valid IP address as a plain text and cannot be added."
    static let dialogHeaderUrlIsNotValid = "Address for checking Internet access is not applicable"
    static let dialogBodyUrlIsNotValid = "The address for checking Internet access does not return correct data and cannot be used."
    static let dialogHeaderWrongScriptFile = "Input application or shell script file is not found or wrong one"
    static let dialogBodyWrongScriptFile = "Error: '%1$@'\nSelect a valid application or shell script file. "
    static let dialogHeaderIpInfoApiIsNotValid = "API for getting information of public IP address is not valid"
    static let dialogBodyIpInfoApiIsNotValid = "API doesn't return a JSON data and cannot be added."
    static let dialogHeaderIpInfoApiMappingIsNotValid = "API for getting information of public IP address doesn't return required data."
    static let dialogBodyIpInfoApiMappingIsNotValid = "The API does not return the country code, latitude, or longitude. Please double-check the API values and mapping for correctness."
    static let dialogHeaderLastIpApiCannotBeRemoved = "Cannot remove the last remaining IP API"
    static let dialogBodyLastIpApiCannotBeRemoved = "You're trying to remove the last IP API, which will make the application stop working. To keep the app functional, please add more valid IP APIs (as many as possible) before deleting this one."
    static let dialogHeaderNoInterpreter = "No script interpreter found"
    static let dialogBodyNoInterpreter = "Install a proper interpreter for this script type (Python 3, Ruby, Perl, PHP or Node for JS files).\n\nThis application can work with these interpreters:\n\(pathZsh)\n\(pathPython)\n\(pathRuby)\n\(pathPerl)\n\(pathPhp)\n\(pathAppleScript)\n\(pathJs)"
    
    // MARK: Hints
    static let hintEnableLogging = "Changes to the public IP address will be logged in a file"
    static let hintRunScript = "Run a custom shell script when the public address changes, the new public IP address will be passed as the first argument as a string"
    static let hintApiIsActive = "API is active and in use"
    static let hintApiIsInactive = "API is not active and not in use"
    static let hintNewVaildIpAddress = "A new valid IP address"
    static let hintNewCustomText = "A new custom text"
    static let hintNewVaildUrl = "A new valid URL"
    static let hintNewVaildApiUrl = "A new valid API URL"
    static let hintNewVaildScriptPath = "A new valid application or shell script path"
    static let hintLightColor = "Light theme color"
    static let hintDarkColor = "Dark theme color"
    static let hintKeepApplicationRunning = "The application will be opened after the system starts or if it was closed"
    static let hintMenuBarAdjustment = "Drag menu bar item icons between the sections below to arrange item as you want"
    static let hintIps = "Add an IP address customization with desired custom text and custom color for light and dark theme\nRight click on the customization to display the context menu"
    static let hintIpApis = "Add new public IP API addresses here, the more the better\nAdd an API that returns the public IP address in plain text\nRight click on the API to display the context menu\nIf API marked green, it works properly and in use"
    static let hintIpInfoApi = "The IP info API is needed to get advanced information about a public IP address, such as its location. This allows you to display the country flag in the macOS menu bar, as well as show the address on a map. Typically, data from such APIs is in JSON format. Here, you can assign an API address and map the JSON data values to application values."
    static let hintNotSet = "Not set yet"
    static let hintJsonKey = "JSON data key"
    
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
    static let wnidowTitlePublicIplocation = "Public IP address location"
    static let wnidowTitlePublicIpLog = "Public IP address log"
    
    // MARK: Menu items
    static let menuItemCopy = "Copy"
    static let menuItemShowOnMap = "Show on map"
    static let menuItemShowLog = "Show log"
    static let menuItemSettings = "Settings"
    static let menuItemRefresh = "Refresh"
    static let menuItemAbout = "About"
    static let menuItemQuit = "Quit"
    
    // MARK: Error messages
    static let errorInvalidJson = "Invalid JSON"
    static let errorNoActiveIpApiFound = "Not possible to obtain IP, try to add a new IP API in the Settings to proceed work or check DNS availability"
    static let errorWhenCallingIpAddressApi = "Error when called IP address API '%1$@': '%2$@', API marked as inactive and will be skipped until next application run"
    static let errorIpApiResponseIsInvalid = "IP address API returned invalid IP address"
    static let errorWhenCallingIpInfoApi = "Error when called IP info API: %1$@"
    static let errorFailedToCreateAppSupportFolder: StaticString = "Failed to get Application Support folder"
    static let errorFailedToCreateAppFolder: StaticString = "Failed to create app folder: %{public}s"
    static let errorInvalidLogFileUrl: StaticString = "Invalid log file URL"
    static let errorFailedToCreateLogFile: StaticString = "Failed to create log file: %{public}s"
    static let errorFailedToWriteLogFile: StaticString = "Failed to write to log file: %{public}s"
    static let errorFailedToCreateInputStreamForLogFile: StaticString = "Failed to create input stream for log file"
    static let errorFailedToTrimLogFile: StaticString = "Failed to trim log file: %{public}s"
    static let errorFailedToClearLogFile: StaticString = "Failed to clear log file: %{public}s"
    static let errorReadingLogFile: String = "Error reading log file: %1$@"
    static let errorScriptFailed: String = "Script failed with status: %1$@"
    static let errorScriptCannotBeExecuted: String = "Failed to execute script: %1$@"
    static let errorAppCannotBeRan: String = "Failed to run app: %1$@"
    static let errorTaskCancelled = "Task cancelled"
    static let errorScriptNotExecutable = "Script not executable: %@"
    static let errorScriptTypeNotSupported = "Script not supported: %@"
    static let errorUnsupportedScriptType = "Unsupported script type: %@"
    static let errorInterpreterNotFound = "Interpreter not found: %@"
    static let errorFailedToLocateInterpreter = "Failed to locate interpreter for '%@'"
    
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
        "https://ipapi.co/ip",
        "https://4.ident.me/",
        "https://www.myexternalip.com/raw",
        "https://l2.io/ip",
        "https://api.ip.sb/ip",
        "https://ipv4.ddnspod.com/",
        "https://api.ip.lk/"
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
    
    static let defaultIpInfoApiKeyMapping = [
        "ipAddress" : "query",
        "zipCode" : "zip",
        "countryCode" : "countryCode",
        "countryName" : "country",
        "regionName" : "regionName",
        "cityName" : "city",
        "latitude" : "lat",
        "longitude" : "lon"
    ]
    
    static let readableIpInfoApiKeyMapping = [
        "ipAddress" : "IP address",
        "zipCode" : "Zip code",
        "countryCode" : "Country code",
        "countryName" : "Country name",
        "regionName" : "Region name",
        "cityName" : "City name",
        "latitude" : "Latitude",
        "longitude" : "Longitude"
    ]
}
