//
//  IpInfoApiEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 17.06.2025.
//

import Factory
import SwiftUI

struct IpInfoApiEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.ipService) private var ipService
    @Injected(\.ipApiService) private var ipApiService
    @Injected(\.networkService) private var networkService
    
    @State private var newUrl: String = .init()
    @State private var keyMapping: [String: String] = .init()
    @State private var isNewUrlInvalid = false
    @State private var isKeyMappingInvalid = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfo)
                    .asInfoIcon()
                Text(Constants.hintIpInfoApi)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 10)
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("\(Constants.ipInfoApiUrl):")
                    HStack {
                        TextField(Constants.hintNewVaildUrl, text: $newUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
                VStack {
                    Text(Constants.mappings)
                        .font(.title3)
                    List {
                        ForEach(Array(keyMapping.keys.sorted()), id: \.self) { key in
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
                    }
                }
                .padding(.bottom, 5)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                AsyncButton(Constants.save, action: saveChangesAsync)
                    .disabled(!hasChanges())
                    .pointerOnHover()
                    .bold()
            }
        }
        .alert(isPresented: $isNewUrlInvalid) {
            Alert(title: Text(Constants.dialogHeaderIpInfoApiIsNotValid),
                  message: Text(Constants.dialogBodyIpInfoApiIsNotValid),
                  dismissButton: .default(Text(Constants.ok)))
        }
        .alert(isPresented: $isKeyMappingInvalid) {
            Alert(title: Text(Constants.dialogHeaderIpInfoApiMappingIsNotValid),
                  message: Text(Constants.dialogBodyIpInfoApiMappingIsNotValid),
                  dismissButton: .default(Text(Constants.ok)))
        }
        .padding(5)
        .onAppear(perform: initValues)
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
            
            await MainActor.run {
                isNewUrlInvalid = false
                isKeyMappingInvalid = false
            }
        } catch {
            await handleError(error)
        }
    }
    
    private func validateAndTestSettings() async throws -> IpInfo {
        // Prepare URL
        guard let publicIp = appState.network.publicIp?.ipAddress,
              let checkUrl = ipApiService.prepareIpInfoApiUrl(publicIp: publicIp, ipInfoApiUrl: newUrl) else {
            throw IpInfoApiSettingsError.invalidUrl
        }
        
        // Check URL reachability
        guard try await networkService.isUrlReachableAsync(url: checkUrl) else {
            throw IpInfoApiSettingsError.urlUnreachable
        }
        
        // Test API response
        let testResponse = await ipService.getPublicIpInfoAsync(publicIp: publicIp, keyMapping: keyMapping)
        guard testResponse.success, let ipInfo = testResponse.result else {
            throw IpInfoApiSettingsError.invalidApiResponse
        }
        
        // Verify location data
        guard ipInfo.hasLocation() else {
            throw IpInfoApiSettingsError.missingLocationData
        }
        
        return ipInfo
    }
    
    private func updateAppState(with ipInfo: IpInfo) async {
        await MainActor.run {
            appState.userData.ipInfoApiUrl = newUrl
            appState.userData.ipInfoApiKeyMapping = keyMapping
        }
        
        await networkService.refreshIpAddressesAsync()
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            switch error {
                case IpInfoApiSettingsError.invalidUrl, IpInfoApiSettingsError.urlUnreachable:
                    isNewUrlInvalid = true
                case IpInfoApiSettingsError.missingLocationData:
                    isKeyMappingInvalid = true
                case IpInfoApiSettingsError.invalidApiResponse:
                    isNewUrlInvalid = true
                    isKeyMappingInvalid = true
                default:
                    isNewUrlInvalid = true
            }
        }
    }
    
    func setNewSettings(url: String, keyMapping: [String: String]) {
        self.newUrl = url
        self.keyMapping = keyMapping
    }
    
    // MARK: Inner types
    
    private enum IpInfoApiSettingsError: Error {
        case invalidUrl
        case urlUnreachable
        case invalidApiResponse
        case missingLocationData
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
