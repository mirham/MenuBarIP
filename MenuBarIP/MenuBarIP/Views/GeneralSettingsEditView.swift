//
//  GeneralSettingsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 24.08.2024.
//

import SwiftUI

struct GeneralSettingsEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    @State private var isKeepRunningOn = false
    @State private var showOverKeepApplicationRunning = false
    @State private var newUrl: String = .init()
    @State private var isNewUrlValid = false
    @State private var isNewUrlInvalid: Bool = false
    @State private var isUrlEditMode: Bool = false
    
    private let launchAgentService = LaunchAgentService.shared
    private let networkService = NetworkService.shared
    
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
                .frame(height: 15)
            VStack(alignment: .leading) {
                Text("\(Constants.internetCheckUrl):")
                HStack {
                    TextField(Constants.hintNewVaildUrl, text: $newUrl)
                        .onChange(of: newUrl) {
                            isNewUrlValid = newUrl.isValidUrl()
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isUrlEditMode)
                    AsyncButton(systemImageName: isUrlEditMode ? Constants.iconSave : Constants.iconEdit, action: changeInternetCheckingUrlButtonClickHandlerAsync)
                        .disabled(!isNewUrlValid)
                        .alert(isPresented: $isNewUrlInvalid) {
                            Alert(title: Text(Constants.dialogHeaderUrlIsNotValid),
                                  message: Text(Constants.dialogBodyUrlIsNotValid),
                                  dismissButton: .default(Text(Constants.ok)))
                        }
                        .font(.system(size: 20))
                        .foregroundStyle(isUrlEditMode ? .green : .accentColor)
                        .buttonStyle(BorderlessButtonStyle())
                        .pointerOnHover()
                        .bold()
                }
            }
            .padding()
            Spacer()
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.newUrl = appState.userData.internetCheckUrl
    }
    
    private func renderHelpHint(hint: String) -> some View {
        let result = Text(hint)
            .frame(width: 200)
            .padding()
        
        return result
    }
    
    private func changeInternetCheckingUrlButtonClickHandlerAsync() async {
        if(!isUrlEditMode) {
            isUrlEditMode = true
            return
        }
        
        do {
            let reachabilityResult = try await networkService.isUrlReachableAsync(url: newUrl)
            isNewUrlInvalid = !reachabilityResult
        }
        catch {
            isNewUrlInvalid = true
            return
        }
        
        guard isNewUrlValid else {
            return
        }
        
        appState.userData.internetCheckUrl = newUrl
        
        isNewUrlValid = true
        isNewUrlInvalid = false
        isUrlEditMode = false
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
