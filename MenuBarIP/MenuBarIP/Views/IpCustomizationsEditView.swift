//
//  IpCustomizationsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI
import Network
import RegexBuilder

struct IpCustomizationsEditView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) private var controlActiveState
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var customizationId: UUID?
    @State private var newIp = String()
    @State private var newCustomText = String()
    @State private var newIpLightColor = Color.black
    @State private var newIpDarkColor = Color.white
    @State private var newCustomTextLightColor = Color.black
    @State private var newCustomTextDarkColor = Color.white
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
                                Circle()
                                    .fill(Color(hex: ipCustomization.customLightColor))
                                    .frame(width: 15, height: 15)
                                    .help(Constants.lightColor)
                                Circle()
                                    .fill(Color(hex: ipCustomization.customDarkColor))
                                    .frame(width: 15, height: 15)
                                    .help(Constants.darkColor)
                                Spacer()
                                    .frame(width: 70)
                                Text(ipCustomization.customText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Circle()
                                    .fill(Color(hex: ipCustomization.customTextLightColor))
                                    .frame(width: 15, height: 15)
                                    .help(Constants.lightColor)
                                Circle()
                                    .fill(Color(hex: ipCustomization.customTextDarkColor))
                                    .frame(width: 15, height: 15)
                                    .help(Constants.darkColor)
                            }
                            .contextMenu {
                                Button(action: { editIpCustomization(ipCustomization: ipCustomization) }) {
                                    Text(Constants.edit)
                                }
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
                            VStack(alignment: .leading, spacing: 15) {
                                Text("\(Constants.ip):")
                                Text("\(Constants.customText):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(Constants.hintNewVaildIpAddress, text: $newIp)
                                    .onChange(of: newIp) {
                                        isNewIpValid = newIp.isValidIp()
                                    }
                                TextField(Constants.hintNewCustomText, text: $newCustomText)
                                    .onChange(of: newCustomText) {
                                        newCustomText = escapeCustomText(text: newCustomText as NSString)
                                    }
                            }
                            .padding(.trailing, 10)
                            VStack(alignment: .leading, spacing: 15) {
                                Text("\(Constants.light):")
                                Text("\(Constants.light):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                PopoverColorPicker(color: $newIpLightColor)
                                    .fixedSize()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                                    .overlay(content: {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 1.5)
                                            .padding(1)
                                    })
                                PopoverColorPicker(color: $newCustomTextLightColor)
                                    .fixedSize()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                                    .overlay(content: {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 1.5)
                                            .padding(1)
                                    })
                            }
                            VStack(alignment: .leading, spacing: 15) {
                                Text("\(Constants.dark):")
                                Text("\(Constants.dark):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                PopoverColorPicker(color: $newIpDarkColor)
                                    .fixedSize()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                                    .overlay(content: {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 1.5)
                                            .padding(1)
                                    })
                                PopoverColorPicker(color: $newCustomTextDarkColor)
                                    .fixedSize()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                                    .overlay(content: {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 1.5)
                                            .padding(1)
                                    })
                            }
                        }
                        AsyncButton(
                            customizationId == nil ? Constants.add : Constants.save,
                            action: upsertIpCustomizationAsync)
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
    
    private func upsertIpCustomizationAsync() async {
        let ipInfoResult = await ipService.getIpInfoAsync(ip: newIp)
        
        if (ipInfoResult.error != nil) {
            isNewIpInvalid = true
            return
        }
        
        let ipCustomization = IpCustomization(
            id: customizationId ?? UUID(),
            ipAddress: newIp,
            customText: newCustomText,
            customLightColor: newIpLightColor.toHex() ?? Color.black.toHex()!,
            customDarkColor: newIpDarkColor.toHex() ?? Color.white.toHex()!,
            customTextLightColor: newCustomTextLightColor.toHex() ?? Color.black.toHex()!,
            customTextDarkColor: newCustomTextDarkColor.toHex() ?? Color.white.toHex()!)
        
        if let currentIpIndex = appState.userData.ipCustomizations.firstIndex(
            where: {$0.id == ipCustomization.id || $0.ipAddress == ipCustomization.ipAddress}) {
            appState.userData.ipCustomizations[currentIpIndex] = ipCustomization
            
            let matches = appState.userData.ipCustomizations.filter({$0.ipAddress == newIp})
            
            if(matches.count > 1) {
                appState.userData.ipCustomizations.removeAll(where: {$0.id == matches.last!.id})
            }
        }
        else {
            appState.userData.ipCustomizations.append(ipCustomization)
        }
        
        customizationId = nil
        newIp = String()
        newCustomText = String()
        isNewIpValid = false
        isNewIpInvalid = false
        newIpLightColor = Color.black
        newIpDarkColor = Color.white
        newCustomTextLightColor = Color.black
        newCustomTextDarkColor = Color.white
    }
    
    private func editIpCustomization(ipCustomization: IpCustomization) {
        customizationId = ipCustomization.id
        newIp = ipCustomization.ipAddress
        newCustomText = ipCustomization.customText
        newIpLightColor = Color(hex: ipCustomization.customLightColor)
        newIpDarkColor = Color(hex: ipCustomization.customDarkColor)
        newCustomTextLightColor = Color(hex: ipCustomization.customTextLightColor)
        newCustomTextDarkColor = Color(hex: ipCustomization.customTextDarkColor)
    }
    
    private func deleteIpCustomization(ipCustomization: IpCustomization) {
        appState.userData.ipCustomizations.removeAll(where: {$0 == ipCustomization})
    }
    
    private func escapeCustomText(text: NSString) -> String {
        var result = text.replacingOccurrences(of: "\n", with: "")
        result = String(result.prefix(Constants.maxCustomTextSymbols))
        
        return result
    }
}

#Preview {
    IpCustomizationsEditView().environmentObject(AppState())
}

