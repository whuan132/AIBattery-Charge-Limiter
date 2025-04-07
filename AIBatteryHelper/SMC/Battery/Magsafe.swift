//
//  Magsafe.swift
//  AIBattery
//
//  Created by whuan132 on 2/15/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

/// Represents the state of the MagSafe LED.
enum MagSafeLedState: UInt8, CustomStringConvertible {
    case system = 0x00
    case off = 0x01
    case green = 0x03
    case orange = 0x04
    case errorOnce = 0x05
    case errorPermSlow = 0x06
    case errorPermFast = 0x07
    case errorPermOff = 0x19

    public var description: String {
        switch self {
        case .system: "system"
        case .off: "off"
        case .green: "green"
        case .orange: "orange"
        case .errorOnce: "errorOnce"
        case .errorPermSlow: "errorPermSlow"
        case .errorPermFast: "errorPermFast"
        case .errorPermOff: "errorPermOff"
        }
    }
}

// MARK: - AppleSMC Extension – MagSafe Control

extension AppleSMC {
    /// Sets the MagSafe LED to the specified state.
    func setMagSafeLedState(state: MagSafeLedState) throws {
        Logger.debug("SetMagSafeLedState(\(state)) called")
        let success = write(SMCKeys.magSafeLedKey, [state.rawValue])
        if success != kIOReturnSuccess {
            throw SMCError.writeFailed
        }
    }

    /// Returns the current MagSafe LED state.
    func getMagSafeLedState() throws -> MagSafeLedState {
        Logger.debug("magSafeLedState() called")

        guard let smcVal = getValue(SMCKeys.magSafeLedKey) else {
            throw SMCError.noData
        }
        guard smcVal.dataSize == 1 else {
            throw SMCError.invalidDataLength(Int(smcVal.dataSize))
        }

        let raw = smcVal.bytes[0]

        // Handle known LED states, fallback to .orange if undefined.
        if let state = MagSafeLedState(rawValue: raw),
           [.off, .green, .orange, .errorOnce, .errorPermSlow].contains(state)
        {
            Logger.debug("magSafeLedState() returned \(state)")
            return state
        } else if raw == 0x02 {
            Logger.debug("magSafeLedState() returned .green (special case)")
            return .green
        } else {
            Logger.debug("magSafeLedState() returned default (.orange)")
            return .orange
        }
    }

    /// Returns true if a MagSafe LED exists on the device.
    func checkMagSafeExistence() -> Bool {
        getValue(SMCKeys.magSafeLedKey) != nil
    }

    /// Sets the MagSafe LED to indicate charging (orange) or not charging (green).
    func setMagSafeCharging(charging: Bool) throws {
        try setMagSafeLedState(state: charging ? .orange : .green)
    }

    /// Returns true if the MagSafe is currently indicating charging (orange LED).
    func isMagSafeCharging() throws -> Bool {
        try getMagSafeLedState() == .orange
    }
}
