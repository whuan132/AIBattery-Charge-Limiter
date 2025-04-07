//
//  AppleSMC.swift
//  AIBattery
//
//  Created by whuan132 on 2/15/25.
//  © 2025 COLLWEB. All rights reserved.
//

import Foundation
import IOKit

class AppleSMC {
    private var conn: io_connect_t = 0

    // MARK: - Init

    public static let shared = AppleSMC()
    private init() {
        var result: kern_return_t
        var iterator: io_iterator_t = 0
        let device: io_object_t

        let matchingDictionary: CFMutableDictionary = IOServiceMatching("AppleSMC")
        result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDictionary, &iterator)
        if result != kIOReturnSuccess {
            Logger
                .error("Error IOServiceGetMatchingServices(): " +
                    (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
            return
        }

        device = IOIteratorNext(iterator)
        IOObjectRelease(iterator)
        if device == 0 {
            Logger
                .error("Error IOIteratorNext(): " +
                    (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
            return
        }

        result = IOServiceOpen(device, mach_task_self_, 0, &conn)
        IOObjectRelease(device)
        if result != kIOReturnSuccess {
            Logger
                .error("Error IOServiceOpen(): " +
                    (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
            return
        }
    }

    deinit {
        let result = self.close()
        if result != kIOReturnSuccess {
            Logger
                .error("error close smc connection: " +
                    (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }

    public func close() -> kern_return_t {
        IOServiceClose(conn)
    }

    public func getValue(_ key: String) -> SMCVal_t? {
        var result: kern_return_t = 0
        var val = SMCVal_t(key)

        result = read(&val)
        if result != kIOReturnSuccess {
            Logger
                .error("Error read(\(key)): " +
                    (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
            return nil
        }

        return val
    }

    func write(_ key: String, _ newValue: [UInt8]) -> kern_return_t {
        var value = SMCVal_t(key)
        value.dataSize = UInt32(newValue.count)
        guard newValue.count <= MemoryLayout.size(ofValue: value.bytes) else {
            Logger.error("Error: newValue exceeds bytes array size")
            return KERN_FAILURE
        }
        for (index, byte) in newValue.enumerated() {
            value.bytes[index] = byte
        }
        return write(value)
    }

    private func read(_ value: UnsafeMutablePointer<SMCVal_t>) -> kern_return_t {
        var result: kern_return_t = 0
        var input = SMCKeyData_t()
        var output = SMCKeyData_t()

        input.key = FourCharCode(fromString: value.pointee.key)
        input.data8 = SMCCommand.readKeyInfo.rawValue

        result = call(SMCCommand.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return result
        }

        value.pointee.dataSize = UInt32(output.keyInfo.dataSize)
        value.pointee.dataType = output.keyInfo.dataType.toString()
        input.keyInfo.dataSize = output.keyInfo.dataSize
        input.data8 = SMCCommand.readBytes.rawValue

        result = call(SMCCommand.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return result
        }

        memcpy(&value.pointee.bytes, &output.bytes, Int(value.pointee.dataSize))

        return kIOReturnSuccess
    }

    private func write(_ value: SMCVal_t) -> kern_return_t {
        var input = SMCKeyData_t()
        var output = SMCKeyData_t()

        input.key = FourCharCode(fromString: value.key)
        input.data8 = SMCCommand.writeBytes.rawValue
        input.keyInfo.dataSize = IOByteCount32(value.dataSize)
        input.bytes = (
            value.bytes[0], value.bytes[1], value.bytes[2], value.bytes[3], value.bytes[4], value.bytes[5],
            value.bytes[6], value.bytes[7], value.bytes[8], value.bytes[9], value.bytes[10], value.bytes[11],
            value.bytes[12], value.bytes[13], value.bytes[14], value.bytes[15], value.bytes[16], value.bytes[17],
            value.bytes[18], value.bytes[19], value.bytes[20], value.bytes[21], value.bytes[22], value.bytes[23],
            value.bytes[24], value.bytes[25], value.bytes[26], value.bytes[27], value.bytes[28], value.bytes[29],
            value.bytes[30], value.bytes[31]
        )

        let result = call(SMCCommand.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return result
        }

        return kIOReturnSuccess
    }

    private func call(_ index: UInt8, input: inout SMCKeyData_t, output: inout SMCKeyData_t) -> kern_return_t {
        let inputSize = MemoryLayout<SMCKeyData_t>.stride
        var outputSize = MemoryLayout<SMCKeyData_t>.stride

        return IOConnectCallStructMethod(conn, UInt32(index), &input, inputSize, &output, &outputSize)
    }
}
