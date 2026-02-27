//
//  MenuBarStatusEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

struct MenuBarStatusEditView: @MainActor MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var shownItems = [MenuBarElement]()
    @State private var hiddenItems = [MenuBarElement]()
    @State private var draggedItem: MenuBarElement?
    @State private var menuBarTextSize: Double = Constants.defaultMenuBarTextSize
    @State private var menuBarSpacing: Double = Constants.defaultMenuBarSpacing
    @State private var separatorInsertedDuringDrag: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            hintSection
            itemsSection
            Spacer().frame(height: 10)
            textSizeSection
            spacingSection
            themeColorSection
            Spacer()
        }
        .onAppear {
            setMenuBarTextSize()
            setMenuBarSpacing()
            fillMenuBarElementItems()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var hintSection: some View {
        HStack {
            Image(systemName: Constants.iconInfo)
                .asInfoIcon()
            Text(Constants.hintMenuBarAdjustment)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var itemsSection: some View {
        VStack(alignment: .center) {
            menuBarScrollSection(
                title: Constants.settingsElementShownItems,
                items: $shownItems,
                destinationItems: $hiddenItems,
                keepLastItem: false
            )
            menuBarScrollSection(
                title: Constants.settingsElementHiddenItems,
                items: $hiddenItems,
                destinationItems: $shownItems,
                keepLastItem: true
            )
        }
    }
    
    @ViewBuilder
    private var textSizeSection: some View {
        sliderSection(
            title: Constants.settingsElementItemsSize,
            value: $menuBarTextSize,
            range: 8...16,
            onChangeHandlers: [saveMenuBarTextSize, fillMenuBarElementItems]
        )
    }
    
    @ViewBuilder
    private var spacingSection: some View {
        sliderSection(
            title: Constants.settingsElementSpacing,
            value: $menuBarSpacing,
            range: 1...5,
            onChangeHandlers: [saveMenuBarSpacing, fillMenuBarElementItems]
        )
    }
    
    @ViewBuilder
    private var themeColorSection: some View {
        Toggle(Constants.settingsElementThemeColor, isOn: Binding(
            get: { appState.userData.menuBarUseThemeColor },
            set: { appState.userData.menuBarUseThemeColor = $0 }
        ))
        .withSettingToggleStyle()
    }
    
    // MARK: Private functions
    
    @ViewBuilder
    private func menuBarScrollSection(
        title: String,
        items: Binding<[MenuBarElement]>,
        destinationItems: Binding<[MenuBarElement]>,
        keepLastItem: Bool
    ) -> some View {
        Text(title)
            .asCenteredTitle()
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: menuBarSpacing) {
                ForEach(items.wrappedValue, id: \.id) { item in
                    item
                        .onDrag {
                            self.draggedItem = item
                            self.separatorInsertedDuringDrag = false
                            return NSItemProvider(object: item.image)
                        }
                        .onDrop(of: [.image], delegate: DropViewDelegate(
                            draggedItem: $draggedItem,
                            sourceItems: items,
                            destinationItems: destinationItems,
                            separatorInsertedDuringDrag: $separatorInsertedDuringDrag, item: item,
                            keepLastItem: keepLastItem
                        ))
                }
            }
            .frame(width: 450, alignment: .center)
            .onChange(of: items.wrappedValue, saveMenuBarElementItems)
            .onChange(of: appState.network, fillMenuBarElementItems)
            .onChange(of: appState.userData, fillMenuBarElementItems)
        }
        .asMenuBarPreview()
    }
    
    @ViewBuilder
    private func sliderSection(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        onChangeHandlers: [() -> Void]
    ) -> some View {
        HStack(alignment: .center) {
            VStack {
                Text(title)
                    .asCenteredTitle()
                Slider(value: value, in: range)
                    .onChange(of: value.wrappedValue) { onChangeHandlers.forEach { $0() } }
                    .padding(.leading)
                    .padding(.trailing)
            }
        }
    }
    
    private func fillMenuBarElementItems() {
        let shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme,
            isExampleAllowed: true)
        
        let hiddenItems = getMenuBarElements(
            keys: appState.userData.menuBarHiddenItems,
            appState: appState,
            colorScheme: colorScheme,
            isExampleAllowed: true)
        
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
        self.frame(width: 450, height: 30)
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
