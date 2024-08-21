//
//  IpCustomizationsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI
import Network

struct IpCustomizationsEditView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var newIp = String()
    @State private var newCustomText = String()
    @State private var newLightColor = String()
    @State private var newDarkColor = String()
    @State private var isNewIpValid = false
    @State private var isNewIpInvalid: Bool = false
    
    private let ipService = IpService.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfo)
                    .asInfoIcon()
                Text(Constants.hintIps)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 10)
            VStack(alignment: .center) {
                Text(Constants.settingsElementIps)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                NavigationStack() {
                    List {
                        ForEach(appState.userData.ipCustomizations, id: \.id) { ipCustomization in
                            HStack {
                                Text(ipCustomization.ipAddress)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Text(ipCustomization.customText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Circle()
                                    .fill(Color(hex: ipCustomization.customLightColor))
                                    .frame(width: 10, height: 10)
                                Circle()
                                    .fill(Color(hex: ipCustomization.customDarkColor))
                                    .frame(width: 10, height: 10)
                            }
                            .contextMenu {
                                Button(action: { deleteIpCustomization(ipCustomization: ipCustomization) }) {
                                    Text(Constants.delete)
                                }
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(Constants.ip):")
                                Text("\(Constants.safety):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(Constants.hintNewVaildIpAddress, text: $newIp)
                                    .onChange(of: newIp) {
                                        isNewIpValid = newIp.isValidIp()
                                    }
                            }
                        }
                        AsyncButton(Constants.add, action: addIpCustomizationAsync)
                            .disabled(!isNewIpValid)
                            .alert(isPresented: $isNewIpInvalid) {
                                Alert(title: Text(Constants.dialogHeaderIpAddressIsNotValid),
                                      message: Text(Constants.dialogBodyIpAddressIsNotValid),
                                      dismissButton: .default(Text(Constants.ok)))
                            }
                            .bold()
                            .pointerOnHover()
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func addIpCustomizationAsync() async {
        let ipInfoResult = await ipService.getIpInfoAsync(ip: newIp)
        
        if (ipInfoResult.error != nil) {
            isNewIpInvalid = true
            
            return
        }
        
        var ipCustomization = IpCustomization(
            ipAddress: newIp,
            customText: newCustomText,
            customLightColor: newLightColor,
            customDarkColor: newDarkColor)
        
        if !appState.userData.ipCustomizations.contains(ipCustomization) {
            appState.userData.ipCustomizations.append(ipCustomization)
        }
        else {
            if let currentIpIndex = appState.userData.ipCustomizations.firstIndex(
                where: {$0.ipAddress == ipCustomization.ipAddress}) {
                appState.userData.ipCustomizations[currentIpIndex] = ipCustomization
            }
        }
        
        newIp = String()
        newCustomText = String()
        newLightColor = String()
        newDarkColor = String()
        isNewIpValid = false
        isNewIpInvalid = false
    }
    
    private func deleteIpCustomization(ipCustomization: IpCustomization) {
        appState.userData.ipCustomizations.removeAll(where: {$0 == ipCustomization})
    }
}

#Preview {
    IpCustomizationsEditView().environmentObject(AppState())
}

