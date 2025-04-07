//
//  BatteryXPCService.swift
//  AIBattery
//
//  Created by whuan132 on 2/15/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Darwin
import Foundation
import IOKit.ps
import os.log

// MARK: - Battery XPC Service Implementation

@objc(BatteryXPCService)
class BatteryXPCService: NSObject, BatteryXPCProtocol {
    func enableCharging(withReply reply: @escaping () -> Void) {
        do {
            try AppleSMC.shared.enableCharging()
            try AppleSMC.shared.setMagSafeCharging(charging: true)
        } catch {
            Logger.error("Failed to enable charging: \(error)")
        }
        reply()
    }

    func disableCharging(withReply reply: @escaping () -> Void) {
        do {
            try AppleSMC.shared.disableCharging()
            try AppleSMC.shared.setMagSafeCharging(charging: false)
        } catch {
            Logger.error("Failed to disable charging: \(error)")
        }
        reply()
    }

    func updateMagSafeLed(_ isChargingEnabled: Bool, withReply reply: @escaping () -> Void) {
        do {
            try AppleSMC.shared.setMagSafeCharging(charging: isChargingEnabled)
        } catch {
            Logger.error("Failed to update MagSafe LED: \(error)")
        }
        reply()
    }

    /// Forces battery mode by disabling AC adapter and modifying LED state.
    func forceBatteryMode(withReply reply: @escaping () -> Void) {
        do {
            // Prevent system sleep while on battery
            runSudoCommand("pmset -b disablesleep 1")

            // Set MagSafe LED to system mode (neutral)
            try AppleSMC.shared.setMagSafeLedState(state: .system)

            // Disable adapter if currently enabled
            if try AppleSMC.shared.isAdapterEnabled() {
                try AppleSMC.shared.disableAdapter()
            }
        } catch {
            Logger.error("Failed to force battery mode: \(error)")
        }
        reply()
    }

    /// Re-enables adapter use and clears sleep prevention settings.
    func enableAdapter(withReply reply: @escaping () -> Void) {
        do {
            if try !AppleSMC.shared.isAdapterEnabled() {
                try AppleSMC.shared.enableAdapter()
            }
            // Restore system sleep setting
            runSudoCommand("pmset -b disablesleep 0")
        } catch {
            Logger.error("Failed to enable adapter: \(error)")
        }
        reply()
    }

    /// Returns the current version of the helper tool.
    func getVersion(withReply reply: @escaping (String) -> Void) {
        reply(helperVersion)
    }

    /// Executes a shell command using `bash` with elevated privileges (via `sudo`).
    private func runSudoCommand(_ command: String) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            Logger.error("Failed to execute shell command: \(error.localizedDescription)")
        }
    }
}

// MARK: - XPC Listener Setup

class ServiceDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        // Define the exported protocol
        newConnection.exportedInterface = NSXPCInterface(with: BatteryXPCProtocol.self)
        // Provide the implementation object
        newConnection.exportedObject = BatteryXPCService()
        newConnection.resume()
        return true
    }
}
