//
//  CurrentIpView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI

struct CurrentIpView: IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    var ipService = IpService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text(Constants.publicIp.uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(appState.network.currentIpInfo?.ipAddress.uppercased() ?? Constants.none.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .contextMenu {
                        if(appState.network.currentIpInfo?.ipAddress != nil){
                            Button(action: { AppHelper.copyTextToClipboard(text: appState.network.currentIpInfo!.ipAddress)}) {
                                Text(Constants.menuItemCopy)
                            }
                        }
                    }
                Spacer().frame(height: 1)
                HStack {
                    let flag = getCountryFlag(countryCode: appState.network.currentIpInfo?.countryCode ?? String())
                    Image(nsImage: flag)
                        .resizable()
                        .frame(width: flag.size.width, height: flag.size.height)
                    Text(appState.network.currentIpInfo?.countryName.uppercased() ?? String())
                        .font(.system(size: 12))
                        .bold()
                }
                .opacity(0.7)
            }
        }
    }
}

#Preview {
    CurrentIpView().environmentObject(AppState())
}

