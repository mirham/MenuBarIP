//
//  IpsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI
import Network

struct IpsEditView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var newIp = String()
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
                        ForEach(appState.userData.ips, id: \.ipAddress) { ipAddress in
                            HStack {
                                Text(ipAddress.ipAddress)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Image(nsImage: getCountryFlag(countryCode: ipAddress.countryCode))
                                Text(ipAddress.countryName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Circle()
                                    .fill(Color(hex: ipAddress.customColor))
                                    .frame(width: 10, height: 10)
                            }
                            .contextMenu {
                                Button(action: { deleteIpAddress(ipAddress: ipAddress) }) {
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
                        AsyncButton(Constants.add, action: addIpAddressAsync)
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
    
    private func addIpAddressAsync() async {
        let ipInfoResult = await ipService.getIpInfoAsync(ip: newIp)
        
        if (ipInfoResult.error != nil) {
            isNewIpInvalid = true
            
            return
        }
        
        var ipInfo = IpInfo(ipAddress: newIp, ipAddressInfo: ipInfoResult.result!)
        ipInfo.customText = "sfdf"
        ipInfo.customColor = "#369300"
        
        if !appState.userData.ips.contains(ipInfo) {
            appState.userData.ips.append(ipInfo)
        }
        else {
            if let currentIpIndex = appState.userData.ips.firstIndex(
                where: {$0.ipAddress == ipInfo.ipAddress}) {
                appState.userData.ips[currentIpIndex] = ipInfo
            }
        }
        
        newIp = String()
        isNewIpValid = false
        isNewIpInvalid = false
    }
    
    private func deleteIpAddress(ipAddress: IpInfo) {
        appState.userData.ips.removeAll(where: {$0 == ipAddress})
    }
}

#Preview {
    IpsEditView().environmentObject(AppState())
}

