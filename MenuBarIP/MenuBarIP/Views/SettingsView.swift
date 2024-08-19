//
//  SettingsView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct SettingsView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    var body: some View {
        TabView {
            GeneralSettingsEditView()
                .tabItem {
                    Text(Constants.settingsElementGeneral)
                }
            MenuBarStatusEditView()
                .tabItem {
                    Text(Constants.settingsElementMenubar)
                }
            IpsEditView()
                .tabItem {
                    Text(Constants.settingsElementCustomization)
                }
            IpApisEditView()
                .environmentObject(appState)
                .tabItem {
                    Text(Constants.settingsElementIpAddressApis)
                }
        }
        .onAppear(perform: {
            AppHelper.setUpView(
                viewName: Constants.windowIdSettings,
                onTop: false)
        })
        .onDisappear(perform: {
            appState.views.isSettingsViewShown = false
        })
        .opacity(getViewOpacity(state: controlActiveState))
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}

