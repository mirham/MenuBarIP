//
//  GeneralSettingsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

struct GeneralSettingsEditView: MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.controlActiveState) var controlActiveState
    
    @State private var isKeepRunningOn = false
    @State private var showOverKeepApplicationRunning = false
    @State private var shownItems = [MenuBarElement]()
    @State private var hiddenItems = [MenuBarElement]()
    @State private var draggedItem: MenuBarElement?
    @State private var menuBarTextSize: Double = Constants.defaultMenuBarTextSize
    
    private let launchAgentService = LaunchAgentService.shared
    
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
                ScrollView(.horizontal, showsIndicators: false) {
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
                    .frame(width: 420, alignment: .center)
                    .onChange(of: shownItems, saveMenuBarElementItems)
                    .onChange(of: appState.network, fillMenuBarElementItems)
                    .onChange(of: appState.userData, fillMenuBarElementItems)
                }
                .asMenuBarPreview()
                Text(Constants.settingsElementHiddenItems)
                    .asCenteredTitle()
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .center, spacing: 5) {
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
            Toggle(Constants.settingsElementThemeColor, isOn: Binding(
                get: { appState.userData.menuBarUseThemeColor },
                set: {
                    appState.userData.menuBarUseThemeColor = $0
                }
            ))
            .withSettingToggleStyle()
            Spacer()
                .frame(height: 20)
            HStack(alignment: .center) {
                Toggle(Constants.settingsElementKeepAppRunning, isOn: .init(
                    get: { isKeepRunningOn },
                    set: { _, _ in if isKeepRunningOn {
                        isKeepRunningOn = !launchAgentService.delete()
                        launchAgentService.isLaunchAgentInstalled = false
                    }
                        else {
                            isKeepRunningOn = launchAgentService.create()
                            launchAgentService.isLaunchAgentInstalled = true
                        }
                    }))
                .withSettingToggleStyle()
                .onAppear {
                    let initState = launchAgentService.isLaunchAgentInstalled
                    isKeepRunningOn = initState
                }
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverKeepApplicationRunning = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverKeepApplicationRunning,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintKeepApplicationRunning) })
            }
            Spacer()
        }
        .onAppear() {
            setMenuBarTextSize()
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
    
    private func saveMenuBarElementItems() {
        appState.userData.menuBarShownItems = self.shownItems.map { $0.key}
        appState.userData.menuBarHiddenItems = self.hiddenItems.map { $0.key}
    }
    
    private func saveMenuBarTextSize() {
        appState.userData.menuBarTextSize = self.menuBarTextSize
    }
    
    private func renderHelpHint(hint: String) -> some View {
        let result = Text(hint)
            .frame(width: 200)
            .padding()
        
        return result
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

private extension Image {
    func asHelpIcon() -> some View {
        self.resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
            .padding(.top)
            .padding(.trailing)
    }
}

#Preview {
    GeneralSettingsEditView().environmentObject(AppState())
}
