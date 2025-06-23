//
//  ExecutiveServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.06.2025.
//

import Foundation

protocol ExecutiveServiceType {
    func execute(publicIp: String)
    func determineInterpreterPath (fileUrl: URL) throws -> URL
}
