//
//  Extensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 03.08.2024.
//

import Foundation

extension KeyedDecodingContainer {
    public func decode<T>(
        _ type: CodableIgnored<T>.Type,
        forKey key: Self.Key) throws -> CodableIgnored<T>{
            return CodableIgnored(wrappedValue: nil)
        }
}

extension KeyedEncodingContainer {
    public mutating func encode<T>(
        _ value: CodableIgnored<T>,
        forKey key: KeyedEncodingContainer<K>.Key) throws{
        }
}

extension String {
    func isValidIp() -> Bool {
        var result = false
        
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if self.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            result = true
        }
        else if self.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            result = true
        }
        
        return result
    }
    
    func isValidUrl() -> Bool {
        do {
            let match = try Constants.regexUrl.wholeMatch(in: self)
            return match != nil
        }
        catch {
            return false
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Task where Failure == Error {
    static func synchronous(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success) {
            let semaphore = DispatchSemaphore(value: 0)
            
            Task(priority: priority) {
                defer { semaphore.signal() }
                return try await operation()
            }
            
            semaphore.wait()
        }
}

