//
//  IpAddressContainerView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import SwiftUI
import FlagKit

protocol IpAddressContainerView : CustomizableItemsContainerView {}

extension IpAddressContainerView {
    func getCountryFlag(countryCode: String) -> NSImage {
        return countryCode.isEmpty
            ? NSImage()
            : Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
