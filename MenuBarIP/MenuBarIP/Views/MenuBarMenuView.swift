//
//  MenuBarView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarMenuView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    private var networkStatusService = NetworkService.shared
    private var launchAgentService = LaunchAgentService.shared
    
    var body: some View {
        VStack {
            Text(Constants.publicIp.uppercased())
                .font(.system(size: 12))
                .foregroundStyle(.gray)
            Text(appState.network.publicIpInfo?.ipAddress ?? Constants.none)
                .font(.system(size: 18))
                .bold()
                .foregroundStyle(getIpMainColor(
                    colorScheme: appState.current.colorScheme,
                    currentIpCustomization: appState.current.ipCustomization,
                    forMenu: true))
            VStack {
                Text(appState.network.publicIpInfo?.asAddressString() ?? String())
                    .font(.system(size: 10))
                    .bold()
                    .foregroundStyle(getBaseColor(colorScheme: appState.current.colorScheme, forMenu: true))
                Button(Constants.menuItemShowOnMap, action: publicIpLocationButtonClickHandler)
                Button(Constants.menuItemCopy) {
                    AppHelper.copyTextToClipboard(text: appState.network.publicIpInfo?.ipAddress ?? String())
                }
            }
            .isHidden(hidden: appState.network.publicIpInfo == nil, remove: true)
            Divider()
            Text(Constants.localIp.uppercased())
                .font(.system(size: 12))
                .foregroundStyle(.gray)
            Text(appState.network.localIp ?? Constants.none)
                .font(.system(size: 18))
                .foregroundStyle(getBaseColor(colorScheme: appState.current.colorScheme, forMenu: true))
                .bold()
            Button(Constants.menuItemCopy) {
                AppHelper.copyTextToClipboard(text: appState.network.localIp ?? String())
            }
            .isHidden(hidden: appState.network.localIp == nil, remove: true)
            Divider()
            Button(Constants.menuItemRefresh) {
                networkStatusService.getCurrentIp()
            }
            Divider()
            Button(Constants.menuItemSettings, action: settingsButtonClickHandler)
            Divider()
            Button(Constants.menuItemQuit, action: quitButtonClickHandler)
        }
    }
    
    // MARK: Private functions
    
    private func settingsButtonClickHandler() {
        if(!appState.views.isSettingsViewShown) {
            openWindow(id: Constants.windowIdSettings)
        }
        
        AppHelper.activateView(viewId: Constants.windowIdSettings)
        dismiss()
    }
    
    private func publicIpLocationButtonClickHandler() {
        if(!appState.views.isPublicIpLocationViewShown) {
            openWindow(id: Constants.windowIdPublicIpLocation)
        }
        AppHelper.activateView(viewId: Constants.windowIdPublicIpLocation)
        dismiss()
    }
    
    private func quitButtonClickHandler() {
        launchAgentService.apply()
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    MenuBarMenuView().environmentObject(AppState())
}
