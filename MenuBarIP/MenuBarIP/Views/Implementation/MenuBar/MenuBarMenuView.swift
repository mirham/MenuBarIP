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
    @Environment(\.colorScheme) private var colorScheme
    
    @Injected(\.networkService) private var networkService
    @Injected(\.launchAgentService) private var launchAgentService
    @Injected(\.windowManager) private var windowManager
    
    private var publicIpString: String {
        appState.network.publicIp?.ipAddress ?? Constants.none.uppercased()
    }
    
    private var localIpString: String {
        appState.network.localIp ?? Constants.none.uppercased()
    }
    
    private var publicIpColor: Color {
        getIpColor(
            colorScheme: colorScheme,
            currentCustomization: appState.current.ipCustomization,
            forMenu: true
        )
    }
    
    private var localIpColor: Color {
        getIpColor(
            colorScheme: colorScheme,
            currentCustomization: appState.current.localIpCustomization,
            forMenu: true
        )
    }
    
    private var baseColor: Color {
        getBaseColor(colorScheme: colorScheme, forMenu: false)
    }
    
    var body: some View {
        VStack {
            publicIpSection
            Divider()
            localIpSection
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
    
    // MARK: View sections
    
    @ViewBuilder
    private var publicIpSection: some View {
        VStack {
            Text(Constants.publicIp.uppercased())
                .asMenuItemHeader()
            
            Text(publicIpString)
                .foregroundStyle(publicIpColor)
                .asMenuItemIp()
            
            if let publicIp = appState.network.publicIp {
                VStack {
                    locationSection(for: publicIp)
                    providerSection(for: publicIp)
                    
                    Button(Constants.menuItemCopy) {
                        AppHelper.copyTextToClipboard(text: publicIp.ipAddress)
                    }
                    
                    Button(Constants.menuItemShowOnMap, action: handlePublicIpLocationButtonClick)
                        .isHidden(hidden: !publicIp.hasPhysicalLocation(), remove: true)
                    
                    Button(Constants.menuItemShowLog, action: handleLogButtonClick)
                        .isHidden(hidden: !appState.userData.enableLogging, remove: true)
                }
            }
        }
    }
    
    @ViewBuilder
    private var localIpSection: some View {
        VStack {
            Text(Constants.localIp.uppercased())
                .asMenuItemHeader()
            
            Text(localIpString)
                .foregroundStyle(localIpColor)
                .asMenuItemIp()
            
            if appState.network.localIp != nil {
                Button(Constants.menuItemCopy) {
                    AppHelper.copyTextToClipboard(text: appState.network.localIp ?? "")
                }
            }
        }
    }
    
    @ViewBuilder
    private func locationSection(for ip: IpInfo) -> some View {
        VStack {
            Text(Constants.location.uppercased())
                .asMenuItemHeaderSmall()
            
            Text(ip.asPhysicalAddressString())
                .font(.system(size: 10))
                .bold()
                .foregroundStyle(baseColor)
        }
        .isHidden(hidden: !ip.hasPhysicalLocation(), remove: true)
    }
    
    @ViewBuilder
    private func providerSection(for ip: IpInfo) -> some View {
        VStack {
            Text(Constants.provider.uppercased())
                .asMenuItemHeaderSmall()
            
            Text(ip.asIspInfoString())
                .font(.system(size: 10))
                .bold()
                .foregroundStyle(baseColor)
        }
        .isHidden(hidden: !ip.hasIspInfo(), remove: true)
    }
    
    // MARK: Private functions
    
    private func handleSettingsButtonClick() {
        windowManager.open(name: .settings, onTop: true)
    }
    
    private func handlePublicIpLocationButtonClick() {
        windowManager.open(name: .publicIpLocation)
    }
    
    private func handleLogButtonClick() {
        windowManager.open(name: .log)
    }
    
    private func handleAboutButtonClick() {
        windowManager.open(name: .info)
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
