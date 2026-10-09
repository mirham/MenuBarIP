//
//  InfoView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 24.08.2024.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.controlActiveState) var controlActiveState
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: Constants.aboutVersionKey) as? String
        ?? String()
    }
    
    private var supportMail: String {
        let data = Data(base64Encoded: Constants.aboutSupportMail)
        return String(data: data!, encoding: .utf8) ?? String()
    }
    
    var body: some View {
        infoContent
            .safeGlassEffect()
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoContent: some View {
        HStack(alignment: .top) {
            aboutInfoSection
        }
        .frame(width: 380, height: 185)
        .opacity(getViewOpacity(state: controlActiveState))
        .background {
            backgroundSection
        }
        .offset(y: -18)
    }
    
    @ViewBuilder
    private var aboutInfoSection: some View {
        VStack(alignment: .leading) {
            Text(String(format: Constants.aboutVersion, appVersion))
                .font(.system(size: 18))
                .padding(.bottom, 10)
            Spacer().frame(height: 30)
            HStack {
                Text(Constants.aboutGetSupport)
                Link(supportMail, destination: URL(string: String(format: Constants.aboutMailTo, supportMail))!)
                    .buttonStyle(.plain)
                    .focusEffectDisabled()
            }
            Link(Constants.aboutGitHub, destination: URL(string: Constants.aboutGitHubLink)!)
                .focusEffectDisabled()
        }
        .padding(.top, 100)
        .padding(.leading, 120)
    }
    
    @ViewBuilder
    private var backgroundSection: some View {
        Image(nsImage: NSImage(named: Constants.aboutBackground) ?? NSImage())
            .resizable()
            .frame(minWidth: 380, maxWidth: 380, minHeight: 220, maxHeight: 220)
    }
}

#Preview {
    InfoView().environmentObject(AppState())
}
