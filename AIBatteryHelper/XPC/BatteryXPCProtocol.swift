//
//  BatteryXPCProtocol.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation

/// Hardcoded helper version
let helperVersion: String = "1.0.1"

// MARK: - Battery XPC Protocol

/// Protocol exposed by the helper tool via XPC.
/// Allows the main app to control battery charging and adapter behavior.
@objc(BatteryXPCProtocol)
protocol BatteryXPCProtocol: NSObjectProtocol {
    /// Enables battery charging.
    /// - Parameter reply: Callback closure upon completion.
    func enableCharging(withReply reply: @escaping () -> Void)

    /// Disables battery charging.
    /// - Parameter reply: Callback closure upon completion.
    func disableCharging(withReply reply: @escaping () -> Void)

    /// Updates the MagSafe LED color based on charging state.
    /// - Parameters:
    ///   - isChargingEnabled: Whether charging should appear active (orange LED).
    ///   - reply: Callback closure upon completion.
    func updateMagSafeLed(_ isChargingEnabled: Bool, withReply reply: @escaping () -> Void)

    /// Forces battery mode even when the adapter is plugged in.
    /// - Parameter reply: Callback closure upon completion.
    func forceBatteryMode(withReply reply: @escaping () -> Void)

    /// Enables the internal adapter (simulated or real).
    /// - Parameter reply: Callback closure upon completion.
    func enableAdapter(withReply reply: @escaping () -> Void)

    /// Returns the current helper version.
    /// - Parameter reply: Closure that returns a string version.
    func getVersion(withReply reply: @escaping (String) -> Void)
}
