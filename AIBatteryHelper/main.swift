//
//  main.swift
//  AIBattery
//
//  Created by whuan132 on 2/15/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation
import IOKit.ps
import os

Logger.info("[AIBatteryHelper] Application starting...")

/// Wrapper class to ensure the XPC listener is retained and running.
class Daemon {
    static let shared = Daemon()

    private let delegate: ServiceDelegate
    private let listener: NSXPCListener

    private init() {
        // Create and configure the XPC listener.
        // `machServiceName` must match the value defined in the helper's launchd `.plist` file under `MachServices`.
        delegate = ServiceDelegate()
        listener = NSXPCListener(machServiceName: "com.collweb.AIBatteryHelper")
        listener.delegate = delegate
        listener.resume()

        Logger.info("[Daemon] NSXPCListener started on machServiceName: com.collweb.AIBatteryHelper")
    }

    /// Runs the daemon's main loop to keep the process alive.
    func run() {
        Logger.info("[Daemon] Entering run loop...")

        // Enter run loop to keep the XPC service alive indefinitely.
        RunLoop.current.run()
    }
}

// Start the XPC daemon
Daemon.shared.run()
