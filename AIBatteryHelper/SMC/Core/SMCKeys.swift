//
//  SMCKeys.swift
//  AIBattery
//
//  Created by whuan132 on 2/15/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

/// SMC keys for Intel-based Macs (x86_64)
private enum SMCKeys_AMD64 {
    static let magSafeLedKey = "ACLC"
    static let acPowerKey = "AC-W"
    static let chargingKey1 = "CH0B"
    static let chargingKey2 = "CH0C"
    static let adapterKey = "CH0K"
    static let batteryChargeKey = "BBIF"
    static let BCLM_KEY = "BCLM"
}

/// SMC keys for Apple Silicon Macs (arm64)
private enum SMCKeys_ARM64 {
    static let magSafeLedKey = "ACLC"
    static let acPowerKey = "AC-W"
    static let chargingKey1 = "CH0B"
    static let chargingKey2 = "CH0C"
    static let adapterKey = "CH0I"
    static let batteryChargeKey = "BUIC"
    static let BCLM_KEY = "CHWA"
}

/// Provides SMC key mappings for the current CPU architecture.
enum SMCKeys {
    /// Returns `true` if the system is running on Apple Silicon (arm64).
    static let isAppleSilicon: Bool = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii) ?? ""
        return machine.contains("arm64")
    }()

    static let magSafeLedKey = isAppleSilicon ? SMCKeys_ARM64.magSafeLedKey : SMCKeys_AMD64.magSafeLedKey
    static let acPowerKey = isAppleSilicon ? SMCKeys_ARM64.acPowerKey : SMCKeys_AMD64.acPowerKey
    static let chargingKey1 = isAppleSilicon ? SMCKeys_ARM64.chargingKey1 : SMCKeys_AMD64.chargingKey1
    static let chargingKey2 = isAppleSilicon ? SMCKeys_ARM64.chargingKey2 : SMCKeys_AMD64.chargingKey2
    static let adapterKey = isAppleSilicon ? SMCKeys_ARM64.adapterKey : SMCKeys_AMD64.adapterKey
    static let batteryChargeKey = isAppleSilicon ? SMCKeys_ARM64.batteryChargeKey : SMCKeys_AMD64.batteryChargeKey
    static let BCLM_KEY = isAppleSilicon ? SMCKeys_ARM64.BCLM_KEY : SMCKeys_AMD64.BCLM_KEY
}
