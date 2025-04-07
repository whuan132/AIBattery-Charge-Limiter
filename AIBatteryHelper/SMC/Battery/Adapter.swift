//
//  Adapter.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

// MARK: - AppleSMC Extension – Adapter Control

extension AppleSMC {
    /// Checks whether the adapter is currently enabled.
    func isAdapterEnabled() throws -> Bool {
        Logger.debug("isAdapterEnabled() called")

        // Attempt to read the adapter SMC key.
        guard let smcVal = getValue(SMCKeys.adapterKey) else {
            throw SMCError.noData
        }

        // Ensure the returned data has exactly 1 byte.
        guard smcVal.dataSize == 1 else {
            throw SMCError.invalidDataLength(Int(smcVal.dataSize))
        }

        // In our convention, 0x0 indicates "enabled".
        let isEnabled = smcVal.bytes[0] == 0x0
        Logger.debug("isAdapterEnabled() returned \(isEnabled)")
        return isEnabled
    }

    /// Enables the power adapter.
    func enableAdapter() throws {
        Logger.debug("enableAdapter() called")

        // Write 0x0 to the adapter key to enable it.
        let result = write(SMCKeys.adapterKey, [0x0])
        if result != kIOReturnSuccess {
            throw SMCError.writeFailed
        }
    }

    /// Disables the power adapter.
    func disableAdapter() throws {
        Logger.debug("disableAdapter() called")

        // Write 0x1 to the adapter key to disable it.
        let result = write(SMCKeys.adapterKey, [0x1])
        if result != kIOReturnSuccess {
            throw SMCError.writeFailed
        }
    }
}
