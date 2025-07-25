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
                VStack() {
                    Text(Constants.location.uppercased())
                        .asMenuItemHeaderSmall()
                    Text(appState.network.publicIp?.asPhysicalAddressString() ?? String())
                        .font(.system(size: 10))
                        .bold()
                        .foregroundStyle(getBaseColor(colorScheme: appState.current.colorScheme, forMenu: true))
                }
                .isHidden(hidden: !(appState.network.publicIp?.hasPhysicalLocation() ?? false), remove: true)
                VStack {
                    Text(Constants.provider.uppercased())
                        .asMenuItemHeaderSmall()
                        .padding(0)
                    Text(appState.network.publicIp?.asIspInfoString() ?? String())
                        .font(.system(size: 10))
                        .bold()
                        .foregroundStyle(getBaseColor(colorScheme: appState.current.colorScheme, forMenu: true))
                }
                .isHidden(hidden: !(appState.network.publicIp?.hasIspInfo() ?? false), remove: true)
                Button(Constants.menuItemCopy) {
                    AppHelper.copyTextToClipboard(text: appState.network.publicIp?.ipAddress ?? String())
                }
                Button(Constants.menuItemShowOnMap, action: handlePublicIpLocationButtonClick)
                    .isHidden(hidden: !(appState.network.publicIp?.hasPhysicalLocation() ?? false), remove: true)
                Button(Constants.menuItemShowLog, action: handleLogButtonClick)
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
            AsyncButton(Constants.menuItemRefresh, action: networkService.refreshIpAddressesManuallyAsync)
            Divider()
            Button(Constants.menuItemSettings, action: handleSettingsButtonClick)
            Divider()
            Button(Constants.menuItemAbout, action: handleAboutButtonClick)
            Divider()
            Button(Constants.menuItemQuit, action: handleQuitButtonClick)
        }
    }
    
    // MARK: Private functions
    
    private func handleSettingsButtonClick() {
        openWindowWithId(id: Constants.windowIdSettings)
    }
    
    private func handlePublicIpLocationButtonClick() {
        openWindowWithId(id: Constants.windowIdPublicIpLocation)
    }
    
    private func handleLogButtonClick() {
        openWindowWithId(id: Constants.windowIdLog)
    }
    
    private func handleAboutButtonClick() {
        openWindowWithId(id: Constants.windowIdInfo)
    }
    
    private func openWindowWithId (id: String) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        if !appState.views.shownWindows.contains(where: {$0 == id}) {
            openWindow(id: id)
        }
    }
    
    private func handleQuitButtonClick() {
        launchAgentService.apply()
        NSApplication.shared.terminate(nil)
    }
}

private extension Text {
    func asMenuItemHeader() -> some View {
        self.font(.system(size: 14))
            .foregroundStyle(.gray)
    }
    
    func asMenuItemIp() -> some View {
        self.font(.system(size: 18))
            .bold()
    }
    
    func asMenuItemHeaderSmall() -> some View {
        self.font(.system(size: 10))
            .foregroundStyle(.gray)
    }
}

#Preview {
    MenuBarMenuView().environmentObject(AppState())
}
