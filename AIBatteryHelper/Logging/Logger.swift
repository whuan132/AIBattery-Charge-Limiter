//
//  Logger.swift
//  AIBattery
//
//  Created by whuan132 on 3/31/25.
//  © 2025 COLLWEB. All rights reserved.
//

import os

enum LogCategory: String {
    case charging = "Charging"
    case adapter = "Adapter"
    case magsafe = "MagSafe"
    case battery = "Battery"
    case acPower = "ACPower"
    case xpc = "XPC"
    case daemon = "Daemon"
    case general = "General"
}

/// A centralized logger for AIBatteryHelper using os_log.
enum Logger {
    private static let subsystem = "com.collweb.AIBatteryHelper"

    static func log(_ message: String, category: LogCategory = .general, type: OSLogType = .default) {
        let logger = OSLog(subsystem: subsystem, category: category.rawValue)
        os_log("%{public}@", log: logger, type: type, message)
    }

    static func error(_ message: String, category: LogCategory = .general) {
        log(message, category: category, type: .error)
    }

    static func info(_ message: String, category: LogCategory = .general) {
        log(message, category: category, type: .info)
    }

    static func fault(_ message: String, category: LogCategory = .general) {
        log(message, category: category, type: .fault)
    }

    #if DEBUG
        static func debug(_ message: String, category: LogCategory = .general) {
            log(message, category: category, type: .debug)
        }
    #else
        static func debug(_: String, category _: LogCategory = .general) {
            // Do nothing in release builds
        }
    #endif
}
