//
//  CustomTextCustomizationsEditView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 25.02.2026.
//

import SwiftUI
import Factory

struct CustomTextCustomizationsEditView : CustomizableItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) private var controlActiveState
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var customizationId: UUID?
    @State private var newMatcher = String()
    @State private var newCustomText = String()
    @State private var newCustomTextLightColor = Color.black
    @State private var newCustomTextDarkColor = Color.white
    @State private var isCustomizationTypeValid = false
    @State private var isCustomizationTypeInvalid: Bool = false
    @State private var isHovered = false
    @State private var selectedType: CustomizableItemType = .unknown
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfo)
                    .asInfoIcon()
                Text(Constants.hintCustomTextCustomization)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 15)
            VStack(alignment: .center) {
                Text(Constants.settingsElementCustomTextCustomization)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                NavigationStack() {
                    List {
                        ForEach(appState.userData.customTextCustomizations, id: \.id) { customization in
                            HStack {
                                Text(customization.type.displayName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                    .frame(width: 70)
                                Text(customization.value)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                    .frame(width: 70)
                                Text(customization.customText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Circle()
                                    .asSelectedColor(colorHex: customization.customTextLightColor, hint: Constants.hintLightColor)
                                Circle()
                                    .asSelectedColor(colorHex: customization.customTextDarkColor, hint: Constants.hintDarkColor)
                            }
                            .contextMenu {
                                Button(action: { editCustomTextCustomization(customization: customization) }) {
                                    Text(Constants.edit)
                                }
                                Button(action: { deleteCustomTextCustomization(customization: customization) }) {
                                    Text(Constants.delete)
                                }
                            }
                        }
                    }
                }
                .padding(10)
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        HStack {
                            Text("\(Constants.informationType):")
                                .frame(width: 110, alignment: .leading)
                            Picker(String(), selection: $selectedType) {
                                ForEach(CustomizableItemType.pickerCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedType) {
                                isCustomizationTypeValid = selectedType != .unknown
                            }
                        }
                        HStack {
                            Text("\(Constants.matcher):")
                                .frame(width: 118, alignment: .leading)
                            TextField(Constants.hintNewVaildMatcher, text: $newMatcher)
                                .onChange(of: newMatcher) {
                                    newMatcher = escapeCustomText(text: newMatcher as NSString)
                                }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Text("\(Constants.customText):")
                                .frame(width: 118, alignment: .leading)
                            TextField(Constants.hintNewCustomText, text: $newCustomText)
                                .onChange(of: newCustomText) {
                                    newCustomText = escapeCustomText(text: newCustomText as NSString)
                                }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.trailing, 10)
                            Text("\(Constants.light):")
                            PopoverColorPicker(color: $newCustomTextLightColor)
                                .asCircle()
                            Text("\(Constants.dark):")
                            PopoverColorPicker(color: $newCustomTextDarkColor)
                                .asCircle()
                        }
                        AsyncButton(
                            customizationId == nil ? Constants.add : Constants.save,
                            action: upsertCustomTextCustomizationAsync)
                            .disabled(!isCustomizationTypeValid)
                            .alert(isPresented: $isCustomizationTypeInvalid) {
                                Alert(title: Text(Constants.dialogHeaderIpAddressIsNotValid),
                                      message: Text(Constants.dialogBodyIpAddressIsNotValid),
                                      dismissButton: .default(Text(Constants.ok)))
                            }
                            .bold()
                            .pointerOnHover()
                    }
                    .padding(10)
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func upsertCustomTextCustomizationAsync() async {
        if selectedType == .unknown {
            isCustomizationTypeInvalid = true
            return
        }
        
        let customTextCustomization = Customization(
            id: customizationId ?? UUID(),
            type: selectedType,
            value: newMatcher,
            customText: newCustomText,
            customLightColor: Color.black.toHex()!,
            customDarkColor: Color.white.toHex()!,
            customTextLightColor: newCustomTextLightColor.toHex() ?? Color.black.toHex()!,
            customTextDarkColor: newCustomTextDarkColor.toHex() ?? Color.white.toHex()!)
        
        if let currentCustomizationIndex = appState.userData.customTextCustomizations.firstIndex(
            where: {$0.id == customTextCustomization.id || $0.value == customTextCustomization.value}) {
            appState.userData.customTextCustomizations[currentCustomizationIndex] = customTextCustomization
            
            let matches = appState.userData.customTextCustomizations.filter({$0.value == newMatcher})
            
            if matches.count > 1 {
                appState.userData.customTextCustomizations.removeAll(where: {$0.id == matches.last!.id})
            }
        }
        else {
            appState.userData.customTextCustomizations.append(customTextCustomization)
        }
        
        customizationId = nil
        selectedType = .unknown
        newMatcher = String()
        newCustomText = String()
        isCustomizationTypeValid = false
        isCustomizationTypeInvalid = false
        newCustomTextLightColor = Color.black
        newCustomTextDarkColor = Color.white
    }
    
    private func editCustomTextCustomization(customization: Customization) {
        customizationId = customization.id
        selectedType = customization.type
        newMatcher = customization.value
        newCustomText = customization.customText
        newCustomTextLightColor = Color(hex: customization.customTextLightColor)
        newCustomTextDarkColor = Color(hex: customization.customTextDarkColor)
    }
    
    private func deleteCustomTextCustomization(customization: Customization) {
        appState.userData.customTextCustomizations.removeAll(where: {$0 == customization})
        
        if appState.userData.customTextCustomizations.isEmpty {
            appState.current.customTextCustomization = nil
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
    CustomTextCustomizationsEditView().environmentObject(AppState())
}

