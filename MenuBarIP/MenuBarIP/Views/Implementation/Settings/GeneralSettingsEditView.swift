//
//  GeneralSettingsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 24.08.2024.
//

import SwiftUI
import Factory

struct GeneralSettingsEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    @Injected(\.networkService) private var networkService
    @Injected(\.launchAgentService) private var launchAgentService
    
    @State private var isKeepRunningOn = false
    @State private var showOverKeepApplicationRunning = false
    @State private var showOverEnableLogging = false
    @State private var showOverRunScript = false
    @State private var scriptPath: String = .init()
    @State private var showFileImporter = false
    @State private var newUrl: String = .init()
    @State private var isNewUrlValid = false
    @State private var isNewUrlInvalid: Bool = false
    @State private var isUrlEditMode: Bool = false
    @State private var logLimit: Int = 0
    @State private var scriptErrorMessage: String = .init()
    @State private var showScriptError = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Toggle(Constants.settingsElementKeepAppRunning, isOn: .init(
                    get: { isKeepRunningOn },
                    set: { _, _ in if isKeepRunningOn {
                        isKeepRunningOn = !launchAgentService.delete()
                        launchAgentService.setState(isInstalled: false)
                    }
                        else {
                            isKeepRunningOn = launchAgentService.create()
                            launchAgentService.setState(isInstalled: true)
                        }
                    }))
                .withSettingToggleStyle()
                .onAppear {
                    let initState = launchAgentService.isInstalled
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
            HStack {
                Toggle(Constants.settingsElementEnableLogging, isOn: Binding(
                    get: { appState.userData.enableLogging },
                    set: { appState.userData.enableLogging = $0 }
                ))
                .withSettingToggleStyle()
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverEnableLogging = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverEnableLogging,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintEnableLogging) })
            }
            .padding(.bottom, 0)
            HStack {
                Text(Constants.settingsElementLogFileLimit)
                    .padding(.leading, 45)
                TextField(Constants.settingsElementLogFileLimit, value: $logLimit, formatter: NumberFormatter())
                    .foregroundColor(checkIfLogIntervalValid(logLimit: logLimit) ? .primary : .red)
                    .onChange(of: logLimit) {
                        if checkIfLogIntervalValid(logLimit: logLimit) {
                            appState.userData.logFileLimit = logLimit
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 59)
            }
            .isHidden(hidden: !appState.userData.enableLogging, remove: true)
            HStack {
                Toggle(Constants.settingsElementRunScript, isOn: Binding(
                    get: { appState.userData.runScript },
                    set: { appState.userData.runScript = $0 }
                ))
                .withSettingToggleStyle()
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverRunScript = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverRunScript,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintRunScript) })
            }
            HStack {
                TextField(Constants.hintNewVaildScriptPath, text:$scriptPath)
                    .padding(.leading, 45)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 350)
                    .help(appState.userData.scriptPath.isEmpty
                          ? Constants.hintNotSet
                          : appState.userData.scriptPath)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Button(Constants.choose) {
                    showFileImporter = true
                }
                .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.shellScript]) { result in
                    selectScriptDialogResultHandler(dialogResult: result)
                }
                .fileDialogDefaultDirectory(.documentsDirectory)
                .alert(isPresented: $showScriptError) {
                    Alert(title: Text(Constants.dialogHeaderWrongScriptFile),
                          message: Text(Constants.dialogBodyWrongScriptFile),
                          dismissButton: .default(Text(Constants.ok),
                                                  action: {
                        scriptErrorMessage = String()
                        showScriptError = false
                    }))
                }
            }
            .isHidden(hidden: !appState.userData.runScript, remove: true)
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
        self.logLimit = appState.userData.logFileLimit
        self.scriptPath = appState.userData.scriptPath
        self.newUrl = appState.userData.internetCheckUrl
    }
    
    private func renderHelpHint(hint: String) -> some View {
        let result = Text(hint)
            .frame(width: 200)
            .padding()
        
        return result
    }
    
    private func checkIfLogIntervalValid(logLimit: Int) -> Bool {
        let result = logLimit >= Constants.minLogFileLimit && logLimit <= Constants.maxLogFileLimit
        
        return result
    }
    
    private func selectScriptDialogResultHandler(dialogResult: Result<URL, any Error>) {
        switch dialogResult {
            case .success(let url):
                let scriptPath = url.path(percentEncoded: false)
                appState.userData.scriptPath = scriptPath
                self.scriptPath = scriptPath
                showFileImporter = false
            case .failure(let error):
                scriptErrorMessage = error.localizedDescription
                showScriptError = true
                showFileImporter = false
        }
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
        
        guard isNewUrlValid else { return }
        
        appState.userData.internetCheckUrl = newUrl
        
        isNewUrlValid = true
        isNewUrlInvalid = false
        isUrlEditMode = false
    }
}

private extension Toggle {
    func withSettingToggleStyle() -> some View {
        self.toggleStyle(CheckToggleStyle())
            .focusEffectDisabled()
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
