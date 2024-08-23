//
//  MenuBarStatusView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarStatusView : MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @MainActor
    var body: some View {
        HStack{
            let image = MenuBarStatusRawView(
                appState: appState,
                colorScheme: colorScheme).renderAsImage()
            Image(nsImage: image!)
                .nonAntialiased()
                .scaledToFit()
        }
        .onAppear(){
            appState.current.colorScheme = colorScheme
        }
        .onChange(of: colorScheme) {
            appState.current.colorScheme = colorScheme
        }
    }
}

// MARK: Inner types

private struct MenuBarStatusRawView: MenuBarItemsContainerView {
    private let appState: AppState
    private let colorScheme: ColorScheme
    
    init(appState: AppState, colorScheme: ColorScheme) {
        self.appState = appState
        self.colorScheme = colorScheme
    }
    
    var body: some View {
        if (appState.network.status != .on) {
            HStack(spacing: appState.userData.menuBarSpacing) {
                Image(systemName: Constants.iconNotConnected)
                Text(Constants.offline.uppercased())
                    .font(.system(size: appState.userData.menuBarTextSize))
            }
            .foregroundStyle(.red)
        }
        else if (appState.network.publicIpInfo == nil && appState.network.obtainingIp) {
            HStack(spacing: appState.userData.menuBarSpacing) {
                Image(systemName: Constants.iconObtaining)
                Text(Constants.obtainingIp.uppercased())
                    .font(.system(size: appState.userData.menuBarTextSize))
            }
        }
        else {
            let shownItems = getMenuBarElements(
                keys: appState.userData.menuBarShownItems,
                appState: appState,
                colorScheme: colorScheme)
            
            HStack(spacing: appState.userData.menuBarSpacing) {
                ForEach(shownItems, id: \.id) { item in
                    Image(nsImage: item.image)
                        .nonAntialiased()
                }
            }
        }
    }
}

#Preview {
    MenuBarStatusView().environmentObject(AppState())
}
