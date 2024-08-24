//
//  IpApisEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI

struct IpApisEditView : View {
    @EnvironmentObject var appState: AppState
    
    private let ipService = IpService.shared
    
    @State private var newUrl = String()
    @State private var isNewUrlValid = false
    @State private var isNewUrlInvalid: Bool = false
    
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
                                Button(action: { appState.userData.ipApis.removeAll(where: {$0 == api})}) {
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
                        AsyncButton(Constants.add, action: addIpApiClickHandlerAsync)
                            .disabled(!isNewUrlValid)
                            .alert(isPresented: $isNewUrlInvalid) {
                                Alert(title: Text(Constants.dialogHeaderApiIsNotValid),
                                      message: Text(Constants.dialogBodyApiIsNotValid),
                                      dismissButton: .default(Text(Constants.ok)))
                            }
                            .pointerOnHover()
                            .bold()
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func addIpApiClickHandlerAsync() async {
        let ipAddressResult = await ipService.getPublicIpAsync(ipApiUrl: newUrl)
        
        guard ipAddressResult.success else {
            isNewUrlInvalid = true
            
            return
        }
        
        let newApi = IpApiInfo(url: newUrl, active: true)
        
        appState.userData.ipApis.append(newApi)
        
        newUrl = String()
        isNewUrlValid = false
        isNewUrlInvalid = false
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
