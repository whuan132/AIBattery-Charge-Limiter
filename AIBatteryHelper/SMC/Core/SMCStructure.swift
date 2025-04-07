//
//  SMCStructure.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

/// Swift version of the SMC value result
struct SMCVal_t {
    var key: String
    var dataSize: UInt32 = 0
    var dataType: String = ""
    var bytes: [UInt8] = Array(repeating: 0, count: 32)

    init(_ key: String) {
        self.key = key
    }
}

/// Internal structure representing SMC data packets exchanged with the kernel
struct SMCKeyData_t {
    /// Raw 32-byte SMC buffer
    typealias SMCBytes_t = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8
    )

    /// Firmware version structure
    struct vers_t {
        var major: CUnsignedChar = 0
        var minor: CUnsignedChar = 0
        var build: CUnsignedChar = 0
        var reserved: CUnsignedChar = 0
        var release: CUnsignedShort = 0
    }

    /// Power limit data
    struct LimitData_t {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }

    /// Key metadata structure
    struct keyInfo_t {
        var dataSize: IOByteCount32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
    }

    var key: UInt32 = 0 // 4-character key ID
    var vers = vers_t() // Version info
    var pLimitData = LimitData_t() // Power limit info
    var keyInfo = keyInfo_t() // Key metadata
    var padding: UInt16 = 0 // Reserved/padding
    var result: UInt8 = 0 // Result code
    var status: UInt8 = 0 // Execution status
    var data8: UInt8 = 0 // 8-bit data value
    var data32: UInt32 = 0 // 32-bit data value
    var bytes: SMCBytes_t = (
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    )
}

/// SMC selector values used to perform specific operations
enum SMCCommand: UInt8 {
    case kernelIndex = 2 // Select kernel index
    case readBytes = 5 // Read bytes from SMC
    case writeBytes = 6 // Write bytes to SMC
    case readIndex = 8 // Read from an index
    case readKeyInfo = 9 // Read key metadata
    case readPLimit = 11 // Read power limit information
    case readVers = 12 // Read firmware version
}
