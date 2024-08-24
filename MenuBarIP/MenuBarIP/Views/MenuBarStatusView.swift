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
            makeOfflineView()
        }
        else if (appState.network.publicIpInfo == nil && appState.network.obtainingIp) {
            makeObtainingIpView()
        }
        else {
            makeDefaultView(appState: appState, colorScheme: colorScheme)
        }
    }
    
    // MARK: Private functions
    
    private func makeOfflineView() -> some View {
        HStack(spacing: appState.userData.menuBarSpacing) {
            Image(systemName: Constants.iconNotConnected)
            Text(Constants.offline.uppercased())
                .font(.system(size: appState.userData.menuBarTextSize))
        }
        .foregroundStyle(.red)
    }
    
    private func makeObtainingIpView() -> some View {
        HStack(spacing: appState.userData.menuBarSpacing) {
            Image(systemName: Constants.iconObtaining)
            Text(Constants.obtainingIp.uppercased())
                .font(.system(size: appState.userData.menuBarTextSize))
        }
    }
    
    @MainActor
    private func makeDefaultView(appState: AppState, colorScheme: ColorScheme) -> some View {
        let shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme)
        
        return HStack(spacing: appState.userData.menuBarSpacing) {
            ForEach(shownItems, id: \.id) { item in
                Image(nsImage: item.image)
                    .nonAntialiased()
            }
        }
    }
}

#Preview {
    MenuBarStatusView().environmentObject(AppState())
}
