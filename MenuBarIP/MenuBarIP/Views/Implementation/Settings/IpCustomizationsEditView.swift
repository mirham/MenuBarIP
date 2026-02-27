//
//  IpCustomizationsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 19.08.2024.
//

import SwiftUI
import Network
import RegexBuilder
import Factory

struct IpCustomizationsEditView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) private var controlActiveState
    @Environment(\.colorScheme) private var colorScheme
    
    @Injected(\.ipService) private var ipService
    
    @State private var customizationId: UUID?
    @State private var newIp = String()
    @State private var newCustomText = String()
    @State private var newIpLightColor = Color.black
    @State private var newIpDarkColor = Color.white
    @State private var newCustomTextLightColor = Color.black
    @State private var newCustomTextDarkColor = Color.white
    @State private var isNewIpValid = false
    @State private var isNewIpInvalid: Bool = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading) {
            hintSection
            Spacer().frame(height: 15)
            ipCustomizationsSection
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var hintSection: some View {
        HStack {
            Image(systemName: Constants.iconInfo)
                .asInfoIcon()
            Text(Constants.hintIps)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var ipCustomizationsSection: some View {
        VStack(alignment: .center) {
            Text(Constants.settingsElementIps)
                .font(.title3)
                .multilineTextAlignment(.center)
            NavigationStack {
                List {
                    ForEach(appState.userData.ipCustomizations, id: \.id) { ipCustomization in
                        ipCustomizationRow(ipCustomization)
                    }
                }
            }
            .padding(10)
            .safeAreaInset(edge: .bottom) {
                ipCustomizationFormSection
            }
        }
    }
    
    @ViewBuilder
    private func ipCustomizationRow(_ ipCustomization: Customization) -> some View {
        HStack {
            Text(ipCustomization.value)
                .frame(maxWidth: .infinity, alignment: .leading)
            Circle()
                .asSelectedColor(colorHex: ipCustomization.customLightColor, hint: Constants.hintLightColor)
            Circle()
                .asSelectedColor(colorHex: ipCustomization.customDarkColor, hint: Constants.hintDarkColor)
            Spacer().frame(width: 70)
            Text(ipCustomization.customText)
                .frame(maxWidth: .infinity, alignment: .leading)
            Circle()
                .asSelectedColor(colorHex: ipCustomization.customTextLightColor, hint: Constants.hintLightColor)
            Circle()
                .asSelectedColor(colorHex: ipCustomization.customTextDarkColor, hint: Constants.hintDarkColor)
        }
        .contextMenu {
            Button(Constants.edit) { editIpCustomization(ipCustomization: ipCustomization) }
            Button(Constants.delete) { deleteIpCustomization(ipCustomization: ipCustomization) }
        }
    }
    
    @ViewBuilder
    private var ipCustomizationFormSection: some View {
        VStack {
            customizableValueRow(
                label: "\(Constants.ip):",
                text: $newIp,
                placeholder: Constants.hintNewVaildIpAddress,
                onTextChange: { isNewIpValid = newIp.isValidIp() },
                lightColor: $newIpLightColor,
                darkColor: $newIpDarkColor
            )
            customizableValueRow(
                label: "\(Constants.customText):",
                text: $newCustomText,
                placeholder: Constants.hintNewCustomText,
                onTextChange: { newCustomText = escapeCustomText(text: newCustomText as NSString) },
                lightColor: $newCustomTextLightColor,
                darkColor: $newCustomTextDarkColor
            )
            AsyncButton(
                customizationId == nil ? Constants.add : Constants.save,
                action: upsertIpCustomizationAsync
            )
            .disabled(!isNewIpValid)
            .alert(isPresented: $isNewIpInvalid) {
                Alert(
                    title: Text(Constants.dialogHeaderIpAddressIsNotValid),
                    message: Text(Constants.dialogBodyIpAddressIsNotValid),
                    dismissButton: .default(Text(Constants.ok))
                )
            }
            .bold()
            .pointerOnHover()
        }
        .padding(10)
    }
    
    // MARK: Private functions
    
    @ViewBuilder
    private func customizableValueRow(
        label: String,
        text: Binding<String>,
        placeholder: String,
        onTextChange: @escaping () -> Void,
        lightColor: Binding<Color>,
        darkColor: Binding<Color>
    ) -> some View {
        HStack {
            Text(label)
                .frame(width: 80, alignment: .leading)
            TextField(placeholder, text: text)
                .onChange(of: text.wrappedValue) { onTextChange() }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("\(Constants.light):")
            PopoverColorPicker(color: lightColor)
                .asCircle()
            Text("\(Constants.dark):")
            PopoverColorPicker(color: darkColor)
                .asCircle()
        }
    }
    
    private func upsertIpCustomizationAsync() async {
        let isLocalIp = ipService.isLocalIp(ipString: newIp)
        
        if !isLocalIp {
            let ipInfoResult = await ipService.getPublicIpInfoAsync(
                apiUrl: appState.userData.ipInfoApiUrl,
                publicIp: newIp,
                keyMapping: appState.userData.ipInfoApiKeyMapping)
            
            if ipInfoResult.error != nil {
                isNewIpInvalid = true
                return
            }
        }
        
        let ipCustomization = Customization(
            id: customizationId ?? UUID(),
            type: .ip,
            value: newIp,
            customText: newCustomText,
            customLightColor: newIpLightColor.toHex() ?? Color.black.toHex()!,
            customDarkColor: newIpDarkColor.toHex() ?? Color.white.toHex()!,
            customTextLightColor: newCustomTextLightColor.toHex() ?? Color.black.toHex()!,
            customTextDarkColor: newCustomTextDarkColor.toHex() ?? Color.white.toHex()!)
        
        if let currentIpIndex = appState.userData.ipCustomizations.firstIndex(
            where: {$0.id == ipCustomization.id || $0.value == ipCustomization.value}) {
            appState.userData.ipCustomizations[currentIpIndex] = ipCustomization
            
            let matches = appState.userData.ipCustomizations.filter({$0.value == newIp})
            
            if matches.count > 1 {
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
    
    private func editIpCustomization(ipCustomization: Customization) {
        customizationId = ipCustomization.id
        newIp = ipCustomization.value
        newCustomText = ipCustomization.customText
        newIpLightColor = Color(hex: ipCustomization.customLightColor)
        newIpDarkColor = Color(hex: ipCustomization.customDarkColor)
        newCustomTextLightColor = Color(hex: ipCustomization.customTextLightColor)
        newCustomTextDarkColor = Color(hex: ipCustomization.customTextDarkColor)
    }
    
    private func deleteIpCustomization(ipCustomization: Customization) {
        appState.userData.ipCustomizations.removeAll(where: {$0 == ipCustomization})
        
        if appState.userData.ipCustomizations.isEmpty {
            appState.current.ipCustomization = nil
            appState.current.publicIpCustomText = nil
        }
    }
    
    private func escapeCustomText(text: NSString) -> String {
        var result = text.replacingOccurrences(of: Constants.newLine, with: String())
        result = String(result.prefix(Constants.maxCustomTextSymbols))
        
        return result
    }
}

private extension PopoverColorPicker {
    func asCircle() -> some View {
        self.fixedSize()
            .frame(width: 20, height: 20)
            .offset(x: -10)
            .scaleEffect(1.2)
            .clipShape(Circle())
            .overlay(content: {
                Circle()
                    .stroke(Color.primary, lineWidth: 1.5)
                    .padding(1)
            })
    }
}

private extension Circle {
    func asSelectedColor(colorHex: String, hint: String) -> some View {
        self.fill(Color(hex: colorHex))
            .frame(width: 15, height: 15)
            .help(hint)
    }
}

#Preview {
    IpCustomizationsEditView().environmentObject(AppState())
}

