//
//  MenuBarView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    private var launchAgentService = LaunchAgentService.shared
    
    @State private var overSettings = false
    @State private var overQuit = false
    
    var body: some View {
        VStack{
            CurrentIpView()
                .environmentObject(appState)
            Spacer()
                .frame(height: 5)
            HStack {
                Button(Constants.show, systemImage: Constants.iconSettings) {
                    settingsButtonClickHandler()
                }
                .withMenuBarButtonStyle(bold: overSettings, color: overSettings ? .blue : .gray)
                .onHover(perform: { hovering in
                    overSettings = hovering
                })
                Spacer()
                    .frame(width: 20)
                Button(Constants.quit, systemImage: Constants.iconQuit) {
                    launchAgentService.apply()
                    NSApplication.shared.terminate(nil)
                }
                .withMenuBarButtonStyle(bold: overQuit, color: overQuit ? .red : .gray)
                .onHover(perform: { hovering in
                    overQuit = hovering
                })
            }
        }
    }
    
    // MARK: Private functions
    
    private func settingsButtonClickHandler(){
        if(!appState.views.isSettingsViewShown){
            openWindow(id: Constants.windowIdSettings)
            AppHelper.activateView(viewId: Constants.windowIdSettings)
            appState.views.isSettingsViewShown = true
        }
        else {
            AppHelper.activateView(viewId: Constants.windowIdSettings)
        }
        dismiss()
    }
}

private extension Button {
    func withMenuBarButtonStyle(bold: Bool, color: Color) -> some View {
        self.buttonStyle(.plain)
            .focusEffectDisabled()
            .foregroundColor(color)
            .bold(bold)
    }
}

#Preview {
    MenuBarView().environmentObject(AppState())
}
