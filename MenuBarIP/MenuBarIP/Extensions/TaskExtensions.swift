//
//  TaskExtensions.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 16.05.2025.
//

import Foundation

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
