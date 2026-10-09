//
//  MenuBarStatusView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI
import Factory

struct MenuBarStatusView: MenuBarItemsContainerView {
    @Injected(\.appState) private var appState
    @Injected(\.appAppearance) private var appearance
    
    var body: some View {
        let _ = appState.menuBarRenderInput
        
        let image = MenuBarStatusRawView(
            appState: appState,
            colorScheme: appearance.colorScheme)
            .renderAsImage()
        
        HStack {
            if let image {
                Image(nsImage: image)
                    .nonAntialiased()
                    .scaledToFit()
            }
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
        switch true {
            case appState.network.status == .off:
                makeOfflineView()
            case appState.network.isObtainingIp:
                makeObtainingIpView()
            case !appState.userData.hasActiveIpApi():
                makeNoActiveIpApiView()
            default:
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
    
    private func makeNoActiveIpApiView() -> some View {
        HStack(spacing: appState.userData.menuBarSpacing) {
            Image(systemName: Constants.iconNoActiveIpApi)
            Text(Constants.noActiveIpApi.uppercased())
                .font(.system(size: appState.userData.menuBarTextSize))
        }
        .foregroundStyle(.orange)
    }
    
    private func makeObtainingIpView() -> some View {
        HStack(spacing: appState.userData.menuBarSpacing) {
            Image(systemName: Constants.iconObtaining)
            Text(Constants.obtainingIp.uppercased())
                .font(.system(size: appState.userData.menuBarTextSize))
        }
        .foregroundStyle(getBaseColor(colorScheme: colorScheme))
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
    MenuBarStatusView()
}
