//
//  WindowType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 14.05.2026.
//

import Foundation

enum WindowType: String, Hashable {
    case settings = "settings-view"
    case publicIpLocation = "public-ip-location-view"
    case log = "log-view"
    case info = "info-view"
    case dialogIpAddressIsNotValid = "dialog-ip-address-not-valid"
    case dialogApiIsNotValid = "dialog-api-not-valid"
    case dialogNoAllowedIp = "dialog-no-allowed-ip"
    case dialogUrlIsNotValid = "dialog-url-not-valid"
    case dialogWrongScriptFile = "dialog-wrong-script-file"
    case dialogIpInfoApiIsNotValid = "dialog-ip-info-api-not-valid"
    case dialogIpInfoApiMappingIsNotValid = "dialog-ip-info-api-mapping-not-valid"
    case dialogLastIpApiCannotBeRemoved = "dialog-last-ip-api-cannot-removed"
    case dialogNoInterpreter = "dialog-no-interpreter"
    
    var title: String {
        switch self {
            case .settings: return Constants.menuItemSettings
            case .publicIpLocation: return Constants.wnidowTitlePublicIplocation
            case .log: return Constants.wnidowTitlePublicIpLog
            case .info: return Constants.info
            case .dialogIpAddressIsNotValid: return String()
            case .dialogNoAllowedIp: return String()
            case .dialogUrlIsNotValid: return String()
            case .dialogWrongScriptFile: return String()
            case .dialogIpInfoApiIsNotValid: return String()
            case .dialogIpInfoApiMappingIsNotValid: return String()
            case .dialogLastIpApiCannotBeRemoved: return String()
            case .dialogNoInterpreter: return String()
            case .dialogApiIsNotValid: return String()
        }
    }
    
    var glassTitlebar: Bool {
        switch self {
            case .settings: return true
            case .publicIpLocation: return true
            case .log: return true
            case .info: return true
            case .dialogIpAddressIsNotValid: return true
            case .dialogNoAllowedIp: return true
            case .dialogUrlIsNotValid: return true
            case .dialogWrongScriptFile: return true
            case .dialogIpInfoApiIsNotValid: return true
            case .dialogIpInfoApiMappingIsNotValid: return true
            case .dialogLastIpApiCannotBeRemoved: return true
            case .dialogNoInterpreter: return true
            case .dialogApiIsNotValid: return true
        }
    }
    
    var hideTitleBar: Bool {
        switch self {
            case .settings: return false
            case .publicIpLocation: return false
            case .log: return false
            case .info: return true
            case .dialogIpAddressIsNotValid: return true
            case .dialogNoAllowedIp: return true
            case .dialogUrlIsNotValid: return true
            case .dialogWrongScriptFile: return true
            case .dialogIpInfoApiIsNotValid: return true
            case .dialogIpInfoApiMappingIsNotValid: return true
            case .dialogLastIpApiCannotBeRemoved: return true
            case .dialogNoInterpreter: return true
            case .dialogApiIsNotValid: return true
        }
    }
    
    var resizable: Bool {
        switch self {
            case .settings: return false
            case .publicIpLocation: return true
            case .log: return true
            case .info: return false
            case .dialogIpAddressIsNotValid: return false
            case .dialogNoAllowedIp: return false
            case .dialogUrlIsNotValid: return false
            case .dialogWrongScriptFile: return false
            case .dialogIpInfoApiIsNotValid: return false
            case .dialogIpInfoApiMappingIsNotValid: return false
            case .dialogLastIpApiCannotBeRemoved: return false
            case .dialogNoInterpreter: return false
            case .dialogApiIsNotValid: return false
        }
    }
    
    var size: CGSize? {
        switch self {
            case .settings: return CGSize(width: 680, height: 550)
            case .publicIpLocation: return CGSize(width: 680, height: 550)
            case .log: return CGSize(width: 680, height: 550)
            case .info: return CGSize(width: 360, height: 190)
            case .dialogIpAddressIsNotValid: return nil
            case .dialogNoAllowedIp: return nil
            case .dialogUrlIsNotValid: return nil
            case .dialogWrongScriptFile: return nil
            case .dialogIpInfoApiIsNotValid: return nil
            case .dialogIpInfoApiMappingIsNotValid: return nil
            case .dialogLastIpApiCannotBeRemoved: return nil
            case .dialogNoInterpreter: return nil
            case .dialogApiIsNotValid: return nil
        }
    }
    
    var hiddenButtons: [ButtonType] {
        switch self {
            case .settings: return [.miniaturize, .zoom]
            case .publicIpLocation: return []
            case .log: return []
            case .info: return [.miniaturize, .zoom]
            case .dialogIpAddressIsNotValid: return [.close, .miniaturize, .zoom]
            case .dialogNoAllowedIp: return [.close, .miniaturize, .zoom]
            case .dialogUrlIsNotValid: return [.close, .miniaturize, .zoom]
            case .dialogWrongScriptFile: return [.close, .miniaturize, .zoom]
            case .dialogIpInfoApiIsNotValid: return [.close, .miniaturize, .zoom]
            case .dialogIpInfoApiMappingIsNotValid: return [.close, .miniaturize, .zoom]
            case .dialogLastIpApiCannotBeRemoved: return [.close, .miniaturize, .zoom]
            case .dialogNoInterpreter: return [.close, .miniaturize, .zoom]
            case .dialogApiIsNotValid: return [.close, .miniaturize, .zoom]
        }
    }
}
