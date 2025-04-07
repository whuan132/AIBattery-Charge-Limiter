# 🔧 AIBatteryHelper

**AIBatteryHelper** is the background daemon component of the AIBattery project. It is responsible for low-level communication with macOS's System Management Controller (SMC), enabling advanced battery management such as charging control, discharge mode, and power state monitoring.

This helper runs as a privileged service and communicates with the main app using `NSXPCConnection`, exposing a safe and extensible API to control hardware behavior.

---

## 📁 Project Structure

AIBatteryHelper/
├── main.swift                  # Entry point for the daemon process
├── Logging
├── Scripts
├── SMC/
│   ├── Battery/                # Battery-specific control modules
│   ├── Core/                   # Low-level AppleSMC interaction
│   ├── Error/                  # Custom error definitions
│   └── Power/                  # Power source detection (AC)
├── XPC/                        # XPC protocol definitions and implementation

---

## 📦 Module Overview

### 🔋 `SMC/Battery/`

Encapsulates battery-related SMC logic, including charging, discharging, MagSafe detection, and adapter status.

- `Battery.swift` – Reads battery state and properties  
- `Charging.swift` – Enables/disables charging  
- `Magsafe.swift` – Detects MagSafe connection  
- `Adapter.swift` – Handles power adapter information

### ⚙️ `SMC/Core/`

Handles low-level SMC communication logic with Apple’s SMC hardware, including register access and binary encoding/decoding.

- `AppleSMC.swift` – Central controller for SMC read/write  
- `SMCKeys.swift` – Commonly used SMC keys  
- `SMCStructure.swift` – SMC data structure parsing  
- `SMCExtensions.swift` – Helpful type extensions and utilities

### ❗ `SMC/Error/`

Defines errors that can occur during SMC operations for improved stability and debugging.

- `SMCErrors.swift` – Structured SMC-related errors

### 🔌 `SMC/Power/`

Provides information about AC power connection status.

- `ACPower.swift` – Checks if the Mac is connected to external power

### 📡 `XPC/`

Defines the interprocess communication interface and implementation between the helper tool and the main tray app.

- `BatteryXPCProtocol.swift` – Public protocol exposed to the main app  
- `BatteryXPCService.swift` – Internal implementation of the protocol

---

## 🚀 Startup Flow

1. `main.swift` starts and registers the XPC service.
2. The main app connects via `NSXPCConnection`.
3. Battery-related methods are called through the exposed protocol.
4. Internally, SMC access is performed through the Core modules.

---

## ⚠️ Notes

- All SMC operations must be performed in the helper process due to privilege requirements.
- XPC methods should be thread-safe and scoped to single responsibilities.
- AppleSMC access relies on IOKit and may require macOS 13+.

---

## 🛠 Developer Tips

- Always test on real hardware — the macOS simulator does not support SMC interaction.
- Use `os_log` or `log stream` to trace and debug helper-side activity.
- Structure your error handling with `SMCErrors` for better clarity and resilience.

---

## 📄 License

This module is proprietary and intended for internal use only as part of the AIBattery project.
