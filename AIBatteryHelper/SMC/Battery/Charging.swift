//
//  Charging.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

// MARK: - AppleSMC Extension – Charging Control

extension AppleSMC {
    /// Returns whether battery charging is currently enabled.
    func isChargingEnabled() throws -> Bool {
        Logger.debug("isChargingEnabled() called")

        // Attempt to read ChargingKey1 from SMC.
        guard let smcVal = getValue(SMCKeys.chargingKey1) else {
            throw SMCError.noData
        }

        // Charging status should be exactly 1 byte.
        guard smcVal.dataSize == 1 else {
            throw SMCError.invalidDataLength(Int(smcVal.dataSize))
        }

        // 0x0 indicates charging is enabled.
        let isEnabled = smcVal.bytes[0] == 0x0
        Logger.debug("isChargingEnabled() returned \(isEnabled)")
        return isEnabled
    }

    /// Enables battery charging.
    func enableCharging() throws {
        Logger.debug("enableCharging() called")

        // Write 0x0 to ChargingKey1.
        let result1 = write(SMCKeys.chargingKey1, [0x0])
        if result1 != kIOReturnSuccess {
            throw SMCError.writeFailed
        }

        // Write 0x0 to ChargingKey2.
        let result2 = write(SMCKeys.chargingKey2, [0x0])
        if result2 != kIOReturnSuccess {
            throw SMCError.writeFailed
        }

        // Also ensure adapter is enabled.
        try enableAdapter()
    }

    /// Disables battery charging.
    func disableCharging() throws {
        Logger.debug("disableCharging() called")

        // Write 0x2 to ChargingKey1.
        let result1 = write(SMCKeys.chargingKey1, [0x2])
        if result1 != kIOReturnSuccess {
            throw SMCError.writeFailed
        }

        // Write 0x2 to ChargingKey2.
        let result2 = write(SMCKeys.chargingKey2, [0x2])
        if result2 != kIOReturnSuccess {
            throw SMCError.writeFailed
        }
    }
}
