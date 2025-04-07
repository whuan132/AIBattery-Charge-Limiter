//
//  SMCErrors.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

/// Represents errors that may occur during SMC operations.
enum SMCError: Error {
    /// No data was returned from the SMC for the requested key.
    case noData

    /// The returned data length was not as expected.
    /// - Parameter expected: The length that was expected.
    case invalidDataLength(Int)

    /// Writing to the SMC key failed.
    case writeFailed
}
