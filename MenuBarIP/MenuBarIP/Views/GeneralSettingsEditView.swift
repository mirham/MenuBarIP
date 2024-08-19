//
//  GeneralSettingsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct GeneralSettingsEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    private let launchAgentService = LaunchAgentService.shared
    
    @State private var isKeepRunningOn = false
    
    @State private var showOverKeepApplicationRunning = false
    
    var body: some View {
        VStack(alignment: .leading) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    // MARK: Private functions
    
    private func renderHelpHint(hint: String) -> some View {
        let result = Text(hint)
            .frame(width: 200)
            .padding()
        
        return result
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
