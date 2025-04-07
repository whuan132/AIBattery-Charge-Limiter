//
//  ACPower.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

// MARK: - AppleSMC Extension – AC Power Detection

extension AppleSMC {
    /// Returns `true` if the device is currently connected to external power (AC).
    func isPluggedIn() throws -> Bool {
        Logger.debug("isPluggedIn() called")

        // Attempt to read the AC power status from the SMC key.
        guard let smcVal = getValue(SMCKeys.acPowerKey) else {
            throw SMCError.noData
        }

        // Expect exactly 1 byte of data.
        guard smcVal.dataSize == 1 else {
            throw SMCError.invalidDataLength(Int(smcVal.dataSize))
        }

        // Interpret the byte as Int8: non-zero means plugged in.
        let pluggedIn = Int8(bitPattern: smcVal.bytes[0]) > 0

        Logger.debug("isPluggedIn() returned \(pluggedIn)")
        return pluggedIn
    }
}
