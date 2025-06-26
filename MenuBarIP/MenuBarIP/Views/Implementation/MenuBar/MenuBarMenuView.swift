//
//  MenuBarView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI
import Factory

struct MenuBarMenuView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    @Injected(\.networkService) private var networkService
    @Injected(\.launchAgentService) private var launchAgentService
    
    var body: some View {
        VStack {
            Text(Constants.publicIp.uppercased())
                .asMenuItemHeader()
            Text(appState.network.publicIp?.ipAddress ?? Constants.none.uppercased())
                .foregroundStyle(getIpColor(
                    colorScheme: appState.current.colorScheme,
                    currentIpCustomization: appState.current.ipCustomization,
                    forMenu: true))
                .asMenuItemIp()
            VStack {
                Text(appState.network.publicIp?.asPhysicalAddressString() ?? String())
                    .font(.system(size: 10))
                    .bold()
                    .foregroundStyle(getBaseColor(colorScheme: appState.current.colorScheme, forMenu: true))
                    .isHidden(hidden: !(appState.network.publicIp?.hasPhysicalLocation() ?? false), remove: true)
                Button(Constants.menuItemCopy) {
                    AppHelper.copyTextToClipboard(text: appState.network.publicIp?.ipAddress ?? String())
                }
                Button(Constants.menuItemShowOnMap, action: publicIpLocationButtonClickHandler)
                    .isHidden(hidden: !(appState.network.publicIp?.hasPhysicalLocation() ?? false), remove: true)
                Button(Constants.menuItemShowLog, action: logButtonClickHandler)
                    .isHidden(hidden: !appState.userData.enableLogging, remove: true)
            }
            .isHidden(hidden: appState.network.publicIp == nil, remove: true)
            Divider()
            Text(Constants.localIp.uppercased())
                .asMenuItemHeader()
            Text(appState.network.localIp ?? Constants.none.uppercased())
                .foregroundStyle(getBaseColor(colorScheme: appState.current.colorScheme, forMenu: true))
                .asMenuItemIp()
            Button(Constants.menuItemCopy) {
                AppHelper.copyTextToClipboard(text: appState.network.localIp ?? String())
            }
            .isHidden(hidden: appState.network.localIp == nil, remove: true)
            Divider()
            AsyncButton(Constants.menuItemRefresh, action: networkService.refreshIpAddressesAsync)
            Divider()
            Button(Constants.menuItemSettings, action: settingsButtonClickHandler)
            Divider()
            Button(Constants.menuItemAbout, action: aboutButtonClickHandler)
            Divider()
            Button(Constants.menuItemQuit, action: quitButtonClickHandler)
        }
    }
    
    // MARK: Private functions
    
    private func settingsButtonClickHandler() {
        openWindowWithId(id: Constants.windowIdSettings)
    }
    
    private func publicIpLocationButtonClickHandler() {
        openWindowWithId(id: Constants.windowIdPublicIpLocation)
    }
    
    private func logButtonClickHandler() {
        openWindowWithId(id: Constants.windowIdLog)
    }
    
    private func aboutButtonClickHandler() {
        openWindowWithId(id: Constants.windowIdInfo)
    }
    
    private func openWindowWithId (id: String) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        if (!appState.views.shownWindows.contains(where: {$0 == id})){
            openWindow(id: id)
        }
    }
    
    private func quitButtonClickHandler() {
        launchAgentService.apply()
        NSApplication.shared.terminate(nil)
    }
}

private extension Text {
    func asMenuItemHeader() -> some View {
        self.font(.system(size: 12))
            .foregroundStyle(.gray)
    }
    
    func asMenuItemIp() -> some View {
        self.font(.system(size: 18))
            .bold()
    }
}

#Preview {
    MenuBarMenuView().environmentObject(AppState())
}
