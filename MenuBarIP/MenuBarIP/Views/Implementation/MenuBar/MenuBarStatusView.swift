//
//  MenuBarStatusView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct MenuBarStatusView : @MainActor MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var debouncedAppState: AppState?
    @State private var debounceTask: Task<Void, Never>?
    
    @MainActor
    var body: some View {
        HStack{
            let image = MenuBarStatusRawView(
                appState: debouncedAppState ?? appState,
                colorScheme: colorScheme).renderAsImage()
            Image(nsImage: image!)
                .nonAntialiased()
                .scaledToFit()
        }
        .onAppear(){
            appState.current.colorScheme = colorScheme
            updateDebouncedState()
        }
        .onChange(of: appState.network) {
            updateDebouncedState()
        }
        .onChange(of: colorScheme) {
            appState.current.colorScheme = colorScheme
        }
    }
    
    private func updateDebouncedState() {
        debounceTask?.cancel()
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: Constants.minRefreshingTimeInterval)
            guard !Task.isCancelled else { return }
            
            debouncedAppState = appState
        }
    }
}

// MARK: Inner types

private struct MenuBarStatusRawView: @MainActor MenuBarItemsContainerView {
    private let appState: AppState
    private let colorScheme: ColorScheme
    
    init(appState: AppState, colorScheme: ColorScheme) {
        self.appState = appState
        self.colorScheme = colorScheme
    }
    
    var body: some View {
        if appState.network.status == .off {
            makeOfflineView()
        }
        else if appState.network.isObtainingIp {
            makeObtainingIpView()
        }
        else if !appState.userData.hasActiveIpApi() {
            makeNoActiveIpApiView()
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
