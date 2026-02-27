//
//  IpInfoApiEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 17.06.2025.
//

import SwiftUI
import Factory

struct IpInfoApiEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.ipService) private var ipService
    @Injected(\.ipApiService) private var ipApiService
    @Injected(\.networkService) private var networkService
    
    @State private var newUrl: String = .init()
    @State private var keyMapping: [String: String] = .init()
    @State private var alertType: AlertType? = nil
    @State private var pendingAlert: AlertType? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            hintSection
            Spacer().frame(height: 10)
            VStack(alignment: .center) {
                apiUrlSection
                mappingsSection
            }
        }
        .safeAreaInset(edge: .bottom) {
            saveButtonSection
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
    private var hintSection: some View {
        HStack {
            Image(systemName: Constants.iconInfo)
                .asInfoIcon()
            Text(Constants.hintIpInfoApi)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var apiUrlSection: some View {
        VStack(alignment: .leading) {
            Text("\(Constants.ipInfoApiUrl):")
            TextField(Constants.hintNewVaildApiUrl, text: $newUrl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
    
    @ViewBuilder
    private var mappingsSection: some View {
        VStack {
            Text(Constants.mappings)
                .font(.title3)
            List {
                ForEach(Array(keyMapping.keys.sorted()), id: \.self) { key in
                    mappingRow(key)
                }
            }
        }
        .padding(10)
    }
    
    @ViewBuilder
    private func mappingRow(_ key: String) -> some View {
        HStack {
            Text(Constants.readableIpInfoApiKeyMapping[key] ?? String())
                .frame(width: 100, alignment: .leading)
                .foregroundColor(.primary)
            TextField(Constants.hintJsonKey, text: Binding(
                get: { keyMapping[key] ?? String() },
                set: { keyMapping[key] = $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private var saveButtonSection: some View {
        VStack {
            AsyncButton(Constants.save, action: saveChangesAsync)
                .disabled(!hasChanges())
                .pointerOnHover()
                .bold()
        }
        .padding(10)
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.newUrl = appState.userData.ipInfoApiUrl
        self.keyMapping = appState.userData.ipInfoApiKeyMapping
    }
    
    private func hasChanges() -> Bool {
        let result = appState.userData.ipInfoApiUrl != newUrl
        || appState.userData.ipInfoApiKeyMapping != keyMapping
        
        return result
    }
    
    private func saveChangesAsync() async {
        do {
            let ipInfo = try await validateAndTestSettings()
            
            await updateAppState(with: ipInfo)
        }
        catch {
            await handleError(error)
        }
    }
    
    private func validateAndTestSettings() async throws -> IpInfo {
        // Prepare URL
        guard let publicIp = appState.network.publicIp?.ipAddress,
              let checkUrl = ipApiService.prepareIpInfoApiUrl(publicIp: publicIp, ipInfoApiUrl: newUrl)
        else { throw IpInfoApiSettingsError.invalidUrl }
        
        // Check URL reachability
        guard try await networkService.isUrlReachableAsync(url: checkUrl)
        else { throw IpInfoApiSettingsError.urlUnreachable }
        
        // Test API response
        let testResponse = await ipService.getPublicIpInfoAsync(
            apiUrl: newUrl,
            publicIp: publicIp,
            keyMapping: keyMapping)
        
        guard testResponse.success, let ipInfo = testResponse.result
        else { throw IpInfoApiSettingsError.invalidApiResponse }
        
        // Verify location data
        guard ipInfo.hasLocation()
        else { throw IpInfoApiSettingsError.missingLocationData }
        
        return ipInfo
    }
    
    private func updateAppState(with ipInfo: IpInfo) async {
        await MainActor.run {
            appState.userData.ipInfoApiUrl = newUrl
            appState.userData.ipInfoApiKeyMapping = keyMapping
        }
        
        await networkService.refreshIpAddressesAsync(isManually: false)
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            switch error {
                case IpInfoApiSettingsError.invalidUrl, IpInfoApiSettingsError.urlUnreachable:
                    showAlert(.newUrlInvalid)
                case IpInfoApiSettingsError.missingLocationData:
                    showAlert(.keyMappingInvalid)
                default:
                    showAlert(.newUrlInvalid)
            }
        }
    }
    
    func setNewSettings(url: String, keyMapping: [String: String]) {
        self.newUrl = url
        self.keyMapping = keyMapping
    }
    
    private func showAlert(_ type: AlertType) {
        if alertType == nil {
            alertType = type
        } else {
            pendingAlert = type
        }
    }
    
    // MARK: Inner types
    
    private enum IpInfoApiSettingsError: Error {
        case invalidUrl
        case urlUnreachable
        case invalidApiResponse
        case missingLocationData
    }
    
    private enum AlertType: Identifiable {
        case newUrlInvalid
        case keyMappingInvalid
        
        var id: Int {
            switch self {
                case .newUrlInvalid: return 0
                case .keyMappingInvalid: return 1
            }
        }
        
        var alertContent: (title: String, message: String) {
            switch self {
                case .newUrlInvalid:
                    return (
                        title: Constants.dialogHeaderIpInfoApiIsNotValid,
                        message: Constants.dialogBodyIpInfoApiIsNotValid)
                case .keyMappingInvalid:
                    return (
                        title: Constants.dialogHeaderIpInfoApiMappingIsNotValid,
                        message: Constants.dialogBodyIpInfoApiMappingIsNotValid)
            }
        }
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
