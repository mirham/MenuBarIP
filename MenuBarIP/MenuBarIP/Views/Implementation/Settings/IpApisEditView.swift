//
//  IpApisEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI
import Factory

struct IpApisEditView : View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.ipService) private var ipService
    
    @State private var newUrl = String()
    @State private var isNewUrlValid: Bool = false
    @State private var alertType: AlertType? = nil
    @State private var pendingAlert: AlertType? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfo)
                    .asInfoIcon()
                Text(Constants.hintIpApis)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 10)
            VStack(alignment: .center) {
                Text(Constants.settingsElementIpAddressApis)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                NavigationStack {
                    List {
                        ForEach(appState.userData.ipApis, id: \.id) { api in
                            HStack {
                                Text(api.url)
                                Spacer()
                                Circle()
                                    .fill(api.isActive() ? .green : .red)
                                    .frame(width: 10, height: 10)
                                
                            }
                            .help(api.isActive() ? Constants.hintApiIsActive : Constants.hintApiIsInactive)
                            .contextMenu {
                                Button(action: { String.copyToClipboard(input: api.url) } ) {
                                    Text(Constants.copy)
                                }
                                Button(action: { handleDeleteIpApiClick(ipApiUrl: api.url) }) {
                                    Text(Constants.delete)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 5)
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(Constants.apiUrl):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(Constants.hintNewVaildApiUrl, text: $newUrl)
                                    .onChange(of: newUrl) {
                                        isNewUrlValid = newUrl.isValidUrl()
                                    }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        AsyncButton(Constants.add, action: handleAddIpApiClickAsync)
                            .disabled(!isNewUrlValid)
                            .pointerOnHover()
                            .bold()
                    }
                }
                .padding(5)
            }
        }
        .alert(isPresented: Binding(
            get: { alertType != nil },
            set: { _ in
                alertType = pendingAlert
                pendingAlert = nil
            }
        )) {
            Alert (
                title: Text(alertType?.alertContent.title ?? String()),
                message: Text(alertType?.alertContent.message ?? String()),
                dismissButton: .default(Text(Constants.ok)) {
                    alertType = pendingAlert
                    pendingAlert = nil
                }
            )
        }
    }
    
    // MARK: Private functions
    
    private func handleAddIpApiClickAsync() async {
        let ipAddressResult = await ipService.getPublicIpAsync(ipApiUrl: newUrl, withInfo: true)
        
        guard ipAddressResult.success else {
            showAlert(.ipApiInvalid)
            
            return
        }
        
        guard !appState.userData.ipApis.contains(where: {$0.url == newUrl})
        else { return }
        
        let newApi = IpApiInfo(url: newUrl, active: true)
        
        appState.userData.ipApis.append(newApi)
        
        newUrl = String()
        isNewUrlValid = false
    }
    
    private func handleDeleteIpApiClick(ipApiUrl: String) {
        guard appState.userData.ipApis.count > Constants.minIpApiCount
        else {
            showAlert(.lastIpApi)
            
            return
        }
        
        appState.userData.ipApis.removeAll(where: {$0.url == ipApiUrl})
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
        case ipApiInvalid
        case lastIpApi
        
        var id: Int {
            switch self {
                case .ipApiInvalid: return 0
                case .lastIpApi: return 1
            }
        }
        
        var alertContent: (title: String, message: String) {
            switch self {
                case .ipApiInvalid:
                    return (
                        title: Constants.dialogHeaderApiIsNotValid,
                        message: Constants.dialogBodyApiIsNotValid)
                case .lastIpApi:
                    return (
                        title: Constants.dialogHeaderLastIpApiCannotBeRemoved,
                        message: Constants.dialogBodyLastIpApiCannotBeRemoved)
            }
        }
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
