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
            IpCustomizationsEditView()
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
            appState.views.shownWindows.append(Constants.windowIdSettings)
            AppHelper.setUpView(
                viewName: Constants.windowIdSettings,
                onTop: true)
        })
        .onDisappear(perform: {
            appState.views.shownWindows.removeAll(where: {$0 == Constants.windowIdSettings})
        })
        .opacity(getViewOpacity(state: controlActiveState))
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}

