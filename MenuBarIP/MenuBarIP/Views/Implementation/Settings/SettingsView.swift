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
            .offset(y: -25)
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
                    icon: Constants.iconMenubar
                ) {
                    MenuBarStatusEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpCustomization,
                    icon: Constants.iconPaintbrush
                ) {
                    IpCustomizationsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementCustomTextCustomization,
                    icon: Constants.iconPaintbrush
                ) {
                    CustomTextCustomizationsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpAddressApis,
                    icon: Constants.iconBulletRectangle
                ) {
                    IpApisEditView()
                        .environmentObject(appState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpInfoApi,
                    icon: Constants.iconBulletRectangle
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

