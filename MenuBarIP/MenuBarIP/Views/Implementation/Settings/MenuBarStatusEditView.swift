//
//  MenuBarStatusEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

struct MenuBarStatusEditView: MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var shownItems = [MenuBarElement]()
    @State private var hiddenItems = [MenuBarElement]()
    @State private var draggedItem: MenuBarElement?
    @State private var menuBarTextSize: Double = Constants.defaultMenuBarTextSize
    @State private var menuBarSpacing: Double = Constants.defaultMenuBarSpacing
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfo)
                    .asInfoIcon()
                Text(Constants.hintMenuBarAdjustment)
                    .padding(.top)
                    .padding(.trailing)
            }
            VStack(alignment: .center) {
                Text(Constants.settingsElementShownItems)
                    .asCenteredTitle()
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: menuBarSpacing) {
                        ForEach(shownItems, id: \.id) { item in
                            item
                                .onDrag({
                                    self.draggedItem = item
                                    return NSItemProvider(object: item.image)
                                })
                                .onDrop(of: [.image], delegate: DropViewDelegate(
                                    draggedItem: $draggedItem,
                                    sourceItems: $shownItems,
                                    destinationItems: $hiddenItems,
                                    item: item,
                                    keepLastItem: false))
                        }
                    }
                    .frame(width: 420, alignment: .center)
                    .onChange(of: shownItems, saveMenuBarElementItems)
                    .onChange(of: appState.network, fillMenuBarElementItems)
                    .onChange(of: appState.userData, fillMenuBarElementItems)
                }
                .asMenuBarPreview()
                Text(Constants.settingsElementHiddenItems)
                    .asCenteredTitle()
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .center, spacing: menuBarSpacing) {
                        ForEach(hiddenItems, id: \.id) { item in
                            item
                                .onDrag {
                                    self.draggedItem = item
                                    return NSItemProvider(object: item.image)
                                }
                                .onDrop(of: [.image], delegate: DropViewDelegate(
                                    draggedItem: $draggedItem,
                                    sourceItems: $hiddenItems,
                                    destinationItems: $shownItems,
                                    item: item,
                                    keepLastItem: true))
                        }
                    }
                    .frame(width: 420, alignment: .center)
                    .onChange(of: hiddenItems, saveMenuBarElementItems)
                    .onChange(of: appState.network, fillMenuBarElementItems)
                    .onChange(of: appState.userData, fillMenuBarElementItems)
                }
                .asMenuBarPreview()
            }
            Spacer()
                .frame(height: 10)
            HStack(alignment: .center) {
                VStack {
                    Text(Constants.settingsElementItemsSize)
                        .asCenteredTitle()
                    Slider(value: $menuBarTextSize, in: 8...16)
                        .onChange(of: menuBarTextSize, saveMenuBarTextSize)
                        .onChange(of: menuBarTextSize, fillMenuBarElementItems)
                        .padding(.leading)
                        .padding(.trailing)
                }
            }
            HStack(alignment: .center) {
                VStack {
                    Text(Constants.settingsElementSpacing)
                        .asCenteredTitle()
                    Slider(value: $menuBarSpacing, in: 1...5)
                        .onChange(of: menuBarSpacing, saveMenuBarSpacing)
                        .onChange(of: menuBarSpacing, fillMenuBarElementItems)
                        .padding(.leading)
                        .padding(.trailing)
                }
            }
            Toggle(Constants.settingsElementThemeColor, isOn: Binding(
                get: { appState.userData.menuBarUseThemeColor },
                set: {
                    appState.userData.menuBarUseThemeColor = $0
                }
            ))
            .withSettingToggleStyle()
            Spacer()
        }
        .onAppear() {
            setMenuBarTextSize()
            setMenuBarSpacing()
            fillMenuBarElementItems()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    // MARK: Private functions
    
    private func fillMenuBarElementItems() {
        let shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme,
            exampleAllowed: true)
        
        let hiddenItems = getMenuBarElements(
            keys: appState.userData.menuBarHiddenItems,
            appState: appState,
            colorScheme: colorScheme,
            exampleAllowed: true)
        
        self.shownItems.removeAll()
        self.hiddenItems.removeAll()
        
        for shownItem in shownItems {
            self.shownItems.append(shownItem)
        }
        
        for hiddenItem in hiddenItems {
            self.hiddenItems.append(hiddenItem)
        }
    }
    
    private func setMenuBarTextSize() {
        self.menuBarTextSize = appState.userData.menuBarTextSize
    }
    
    private func setMenuBarSpacing() {
        self.menuBarSpacing = appState.userData.menuBarSpacing
    }
    
    private func saveMenuBarElementItems() {
        appState.userData.menuBarShownItems = self.shownItems.map { $0.key}
        appState.userData.menuBarHiddenItems = self.hiddenItems.map { $0.key}
    }
    
    private func saveMenuBarTextSize() {
        appState.userData.menuBarTextSize = self.menuBarTextSize
    }
    
    private func saveMenuBarSpacing() {
        appState.userData.menuBarSpacing = self.menuBarSpacing
    }
}

private extension ScrollView {
    func asMenuBarPreview() -> some View {
        self.frame(width: 420, height: 30)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 6
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.blue, lineWidth: 1)
            )
            .padding(.leading)
            .padding(.trailing)
    }
}

private extension Text {
    func asCenteredTitle() -> some View {
        self.font(.title3)
            .padding(.top, 5)
            .padding(.bottom, 5)
    }
}

private extension Toggle {
    func withSettingToggleStyle() -> some View {
        self.toggleStyle(CheckToggleStyle())
            .pointerOnHover()
            .padding(.leading)
            .padding(.top)
    }
}

#Preview {
    GeneralSettingsEditView().environmentObject(AppState())
}
