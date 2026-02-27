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
    @Injected(\.executiveService) private var executiveService
    @Injected(\.launchAgentService) private var launchAgentService
    
    @State private var isKeepRunningOn = false
    @State private var showOverPeriodicIpCheck = false
    @State private var interval: Int = 0
    @State private var showOverKeepApplicationRunning = false
    @State private var showOverEnableLogging = false
    @State private var showOverRunScript = false
    @State private var scriptPath: String = .init()
    @State private var showFileImporter = false
    @State private var newUrl1: String = .init()
    @State private var isNewUrl1Valid = false
    @State private var isNewUrl1EditMode: Bool = false
    @State private var newUrl2: String = .init()
    @State private var isNewUrl2Valid: Bool = false
    @State private var isNewUrl2EditMode: Bool = false
    @State private var newUrl3: String = .init()
    @State private var isNewUrl3Valid: Bool = false
    @State private var isNewUrl3EditMode: Bool = false
    @State private var logLimit: Int = 0
    @State private var showScriptError = false
    @State private var alertType: AlertType? = nil
    @State private var pendingAlert: AlertType? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            keepAppRunningSection
            periodicIpCheckSection
            enableLoggingSection
            runScriptSection
            Spacer().frame(height: 15)
            internetCheckUrlsSection
            Spacer()
        }
        .alert(isPresented: Binding(
            get: { alertType != nil },
            set: { if !$0 { alertType = pendingAlert; pendingAlert = nil } }
        )) {
            Alert(
                title: Text(alertType?.alertContent.title ?? String()),
                message: Text(alertType?.alertContent.message ?? String()),
                dismissButton: .default(Text(Constants.ok)) {
                    alertType = pendingAlert
                    pendingAlert = nil
                }
            )
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var keepAppRunningSection: some View {
        HStack {
            Toggle(Constants.settingsElementKeepAppRunning, isOn: .init(
                get: { isKeepRunningOn },
                set: { _, _ in
                    if isKeepRunningOn {
                        isKeepRunningOn = !launchAgentService.delete()
                        launchAgentService.setState(isInstalled: false)
                    } else {
                        isKeepRunningOn = launchAgentService.create()
                        launchAgentService.setState(isInstalled: true)
                    }
                }
            ))
            .withSettingToggleStyle()
            .onAppear {
                isKeepRunningOn = launchAgentService.isInstalled
            }
            Spacer()
            Image(systemName: Constants.iconQuestionMark)
                .asHelpIcon()
                .onHover { showOverKeepApplicationRunning = $0 && controlActiveState == .key }
                .popover(isPresented: $showOverKeepApplicationRunning, arrowEdge: .trailing) {
                    helpHint(Constants.hintKeepApplicationRunning)
                }
        }
    }
    
    @ViewBuilder
    private var periodicIpCheckSection: some View {
        SettingToggleRow(
            label: Constants.settingsElementPeriodicIpCheck,
            hint: Constants.hintPeriodicIpCheck,
            isOn: $appState.userData.periodicIpCheck
        )
        
        if appState.userData.periodicIpCheck {
            HStack {
                Text(Constants.settingsElementIntervalBegin)
                    .padding(.leading, 45)
                TextField(Constants.hintInterval, value: $interval, formatter: NumberFormatter())
                    .foregroundColor(checkIfTimeIntervalValid(interval: interval) ? .primary : .red)
                    .onChange(of: interval) {
                        if checkIfTimeIntervalValid(interval: interval) {
                            appState.userData.intervalBetweenChecks = interval
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 59)
                Text(Constants.settingsElementIntervalEnd)
            }
        }
    }
    
    @ViewBuilder
    private var enableLoggingSection: some View {
        SettingToggleRow(
            label: Constants.settingsElementEnableLogging,
            hint: Constants.hintEnableLogging,
            isOn: $appState.userData.enableLogging
        )
        
        if appState.userData.enableLogging {
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
        }
    }
    
    @ViewBuilder
    private var runScriptSection: some View {
        SettingToggleRow(
            label: Constants.settingsElementRunScript,
            hint: Constants.hintRunScript,
            isOn: $appState.userData.runScript
        )
        
        if appState.userData.runScript {
            HStack {
                TextField(Constants.hintNewVaildScriptPath, text: $scriptPath)
                    .padding(.leading, 45)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 350)
                    .help(appState.userData.scriptPath.isEmpty
                          ? Constants.hintNotSet
                          : appState.userData.scriptPath)
                    .disabled(true)
                Button(Constants.choose) {
                    showFileImporter = true
                }
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [
                        .executable,
                        .sourceCode,
                        .shellScript,
                        .pythonScript,
                        .appleScript,
                        .javaScript,
                        .perlScript,
                        .phpScript,
                        .rubyScript,
                        .text
                    ]
                ) { result in
                    handleSelectScriptDialogResult(dialogResult: result)
                }
                .fileDialogDefaultDirectory(.applicationDirectory)
            }
        }
    }
    
    @ViewBuilder
    private var internetCheckUrlsSection: some View {
        VStack(alignment: .leading) {
            Text("\(Constants.internetCheckUrl):")
            urlInputView(url: $newUrl1, isEditMode: $isNewUrl1EditMode, isValid: $isNewUrl1Valid, userDataKeyPath: \.internetCheckUrl1)
            urlInputView(url: $newUrl2, isEditMode: $isNewUrl2EditMode, isValid: $isNewUrl2Valid, userDataKeyPath: \.internetCheckUrl2)
            urlInputView(url: $newUrl3, isEditMode: $isNewUrl3EditMode, isValid: $isNewUrl3Valid, userDataKeyPath: \.internetCheckUrl3)
        }
        .padding()
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.interval = appState.userData.intervalBetweenChecks
        self.logLimit = appState.userData.logFileLimit
        self.scriptPath = appState.userData.scriptPath
        self.newUrl1 = appState.userData.internetCheckUrl1
        self.newUrl2 = appState.userData.internetCheckUrl2
        self.newUrl3 = appState.userData.internetCheckUrl3
    }
    
    private func checkIfLogIntervalValid(logLimit: Int) -> Bool {
        let result = logLimit >= Constants.minLogFileLimit && logLimit <= Constants.maxLogFileLimit
        
        return result
    }
    
    private func checkIfTimeIntervalValid(interval: Int) -> Bool {
        let result = interval >= Constants.minTimeIntervalToCheck && interval <= Constants.maxTimeIntervalToCheck
        
        return result
    }
    
    @ViewBuilder
    func urlInputView(
        url: Binding<String>,
        isEditMode: Binding<Bool>,
        isValid: Binding<Bool>,
        userDataKeyPath: WritableKeyPath<AppState.UserData, String>
    ) -> some View {
        HStack {
            TextField(Constants.hintNewVaildUrl, text: url)
                .onChange(of: url.wrappedValue) {
                    isValid.wrappedValue = url.wrappedValue.isValidUrl()
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(!isEditMode.wrappedValue)
            AsyncButton(
                systemImageName: isEditMode.wrappedValue ? Constants.iconSave : Constants.iconEdit
            ) {
                await handleUrlChangeAsync(
                    url: url.wrappedValue,
                    isEditMode: isEditMode,
                    isValid: isValid,
                    alertType: .newUrlInvalid,
                    userDataKeyPath: userDataKeyPath
                )
            }
            .disabled(!isValid.wrappedValue)
            .font(.system(size: 20))
            .foregroundStyle(isEditMode.wrappedValue ? .green : .accentColor)
            .buttonStyle(BorderlessButtonStyle())
            .pointerOnHover()
            .bold()
        }
    }
    
    private func handleUrlChangeAsync(
        url: String,
        isEditMode: Binding<Bool>,
        isValid: Binding<Bool>,
        alertType: AlertType,
        userDataKeyPath: WritableKeyPath<AppState.UserData, String>
    ) async {
        if !isEditMode.wrappedValue {
            isEditMode.wrappedValue = true
            return
        }
        
        do {
            let isReachable = try await networkService.isUrlReachableAsync(url: url)
            
            if !isReachable {
                self.alertType = alertType
                
                return
            }
            isValid.wrappedValue = true
        } catch {
            self.alertType = alertType
            
            return
        }
        
        guard isValid.wrappedValue else { return }
        
        appState.userData[keyPath: userDataKeyPath] = url
        isEditMode.wrappedValue = false
    }
    
    private func handleSelectScriptDialogResult(dialogResult: Result<URL, any Error>) {
        switch dialogResult {
            case .success(let url):
                let scriptPath = url.path(percentEncoded: false)
                
                do {
                    let scriptUrl = URL(string: scriptPath)
                    let pathExtension = scriptUrl?.pathExtension.lowercased()
                    if pathExtension != Constants.fileExtApp {
                        _ = try executiveService.determineInterpreterPath(fileUrl: URL(filePath: scriptPath))
                    }
                }
                catch {
                    showAlert(.interpreterError)
                    
                    return
                }
                
                self.scriptPath = scriptPath
                appState.userData.scriptPath = scriptPath
                showFileImporter = false
            case .failure(let error):
                showAlert(.scriptError(errorText: error.localizedDescription))
        }
    }
    
    private func showAlert(_ type: AlertType) {
        if alertType == nil {
            alertType = type
        } else {
            pendingAlert = type
        }
    }
    
    // MARK: Inner types
    
    private enum AlertType: Identifiable {
        case newUrlInvalid
        case newUrlAlternativeInvalid
        case scriptError(errorText: String)
        case interpreterError
        
        var id: Int {
            switch self {
                case .newUrlInvalid: return 0
                case .newUrlAlternativeInvalid: return 1
                case .scriptError: return 2
                case .interpreterError: return 3
            }
        }
        
        var alertContent: (title: String, message: String) {
            switch self {
                case .newUrlInvalid:
                    return (
                        title: Constants.dialogHeaderUrlIsNotValid,
                        message: Constants.dialogBodyUrlIsNotValid)
                case .newUrlAlternativeInvalid:
                    return (
                        title: Constants.dialogHeaderUrlIsNotValid,
                        message: Constants.dialogBodyUrlIsNotValid)
                case .scriptError(let errorText):
                    return (
                        title: Constants.dialogHeaderWrongScriptFile,
                        message: String(format: Constants.dialogBodyWrongScriptFile, errorText))
                case .interpreterError:
                    return (
                        title: Constants.dialogBodyNoInterpreter,
                        message: Constants.dialogHeaderNoInterpreter)
            }
        }
    }
    
    private struct SettingToggleRow: View {
        let label: String
        let hint: String
        @Binding var isOn: Bool
        @Environment(\.controlActiveState) private var controlActiveState
        
        @State private var showHint = false
        
        var body: some View {
            HStack {
                Toggle(label, isOn: $isOn)
                    .withSettingToggleStyle()
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover { showHint = $0 && controlActiveState == .key }
                    .popover(isPresented: $showHint, arrowEdge: .trailing) {
                        helpHint(hint)
                    }
            }
        }
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

private extension View {
    func helpHint(_ hint: String) -> some View {
        Text(hint)
            .frame(width: 200)
            .padding()
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
