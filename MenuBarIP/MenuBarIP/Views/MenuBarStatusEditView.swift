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
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfo)
                    .asInfoIcon()
                Text(Constants.hintMenuBarAdjustment)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 15)
            VStack(alignment: .center) {
                Text(Constants.settingsElementShownItems)
                    .asCenteredTitle()
                LazyHStack(spacing: 5) {
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
                .asMenuBarPreview()
                .onChange(of: shownItems, saveMenuBarElementItems)
                .onChange(of: appState.network, fillMenuBarElementItems)
                .onChange(of: appState.userData, fillMenuBarElementItems)
                Text(Constants.settingsElementShownItems)
                    .asCenteredTitle()
                LazyHStack(spacing: 5) {
                    ForEach(hiddenItems, id: \.id) { item in
                        item
                            .onDrag({
                                self.draggedItem = item
                                return NSItemProvider(object: item.image)
                            })
                            .onDrop(of: [.image], delegate: DropViewDelegate(
                                draggedItem: $draggedItem,
                                sourceItems: $hiddenItems,
                                destinationItems: $shownItems,
                                item: item,
                                keepLastItem: true))
                    }
                }
                .asMenuBarPreview()
                .onChange(of: hiddenItems, saveMenuBarElementItems)
                .onChange(of: appState.network, fillMenuBarElementItems)
                .onChange(of: appState.userData, fillMenuBarElementItems)
            }
            .frame(maxWidth: .infinity, maxHeight: 150, alignment: .center)
            Spacer()
                .frame(height: 30)
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
    
    private func saveMenuBarElementItems() {
        appState.userData.menuBarShownItems = self.shownItems.map { $0.key}
        appState.userData.menuBarHiddenItems = self.hiddenItems.map { $0.key}
    }
}

private extension LazyHStack {
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
    }
}

private extension Text {
    func asCenteredTitle() -> some View {
        self.font(.title3)
            .padding(.top)
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
    MenuBarStatusEditView().environmentObject(AppState())
}
