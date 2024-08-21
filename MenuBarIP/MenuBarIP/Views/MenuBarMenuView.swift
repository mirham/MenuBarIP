//
//  MenuBarView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarMenuView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    private var launchAgentService = LaunchAgentService.shared
    
    var body: some View {
        VStack {
            Text(appState.network.publicIpInfo?.ipAddress ?? "...")
                .foregroundStyle(.cyan)
            Text(appState.network.localIp ?? "...")
                .foregroundStyle(.yellow)
            Divider()
            Button("Refresh") {}
            Divider()
            Button("Public IP location", action: publicIpLocationButtonClickHandler)
            Divider()
            Button("Copy public IP") {}
            Button("Copy local IP") {}
            Divider()
            Button(Constants.settings, action: settingsButtonClickHandler)
            Divider()
            Button(Constants.quit, action: quitButtonClickHandler)
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
