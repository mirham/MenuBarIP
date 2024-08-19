//
//  MenuBarStatusView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation
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
        let shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme)
        
        HStack(spacing: 5) {
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
