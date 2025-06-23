//
//  UTTypeExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 23.06.2025.
//

import UniformTypeIdentifiers
import SwiftUI

extension UTType {
    static var cSharpScript: UTType {
        UTType("\(Constants.defaultAppBundleName).csharp-script") ?? UTType(filenameExtension: "csx") ?? .text
    }
}
