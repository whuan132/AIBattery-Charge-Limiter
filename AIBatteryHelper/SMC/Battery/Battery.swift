//
//  Battery.swift
//  AIBattery
//
//  Created by whuan132 on 2/15/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

// MARK: - AppleSMC Extension – Battery Charge

extension AppleSMC {
    /// Reads the current battery charge percentage (0–100).
    func getBatteryCharge() throws -> Int {
        Logger.debug("batteryCharge() called")

        // Attempt to read the battery charge key from SMC.
        guard let smcVal = getValue(SMCKeys.batteryChargeKey) else {
            throw SMCError.noData
        }

        // Expect exactly 1 byte of data.
        guard smcVal.dataSize == 1 else {
            throw SMCError.invalidDataLength(Int(smcVal.dataSize))
        }

        // Convert the single byte to Int (assumed range: 0–100).
        return Int(smcVal.bytes[0])
    }
}
