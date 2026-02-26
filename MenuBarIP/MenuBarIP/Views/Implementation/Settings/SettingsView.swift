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
        VStack {
            HStack {
                Spacer()
                    .frame(width: 30)
                Text(Constants.menuItemSettings)
                    .font(.headline)
                Spacer()
            }
            .offset(y: -22)
            FixedSidebarTabView {
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementGeneral,
                    icon: Constants.iconGear
                ) {
                    GeneralSettingsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementMenubar,
                    icon: "menubar.rectangle"
                ) {
                    MenuBarStatusEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpCustomization,
                    icon: "paintbrush"
                ) {
                    IpCustomizationsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementCustomTextCustomization,
                    icon: "paintbrush"
                ) {
                    CustomTextCustomizationsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpAddressApis,
                    icon: "list.bullet.rectangle"
                ) {
                    IpApisEditView()
                        .environmentObject(appState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpInfoApi,
                    icon: "list.bullet.rectangle"
                ) {
                    IpInfoApiEditView()
                        .environmentObject(appState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}

