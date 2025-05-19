//
//  IpApiServiceType.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

protocol IpApiServiceType {
    func getRandomActiveIpApi() -> IpApiInfo?
    func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String>
    func reactivateIpApis()
}
