#!/bin/bash

# Set script to exit immediately on failure
set -e

# Color codes for log output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing AIBatteryHelper...${NC}"

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script requires root privileges. Please run with sudo.${NC}"
    exit 1
fi

# Define the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define files and paths
HELPER_BINARY="$SCRIPT_DIR/AIBatteryHelper"
HELPER_PLIST="$SCRIPT_DIR/com.collweb.AIBatteryHelper.plist"
INSTALL_DIR="/Library/Application Support/AIBatteryHelper/"
LAUNCH_DAEMONS="/Library/LaunchDaemons/"

# Verify that the input files exist
if [ ! -f "$HELPER_BINARY" ]; then
    echo -e "${RED}Error: AIBatteryHelper binary not found at $HELPER_BINARY.${NC}"
    exit 1
fi

if [ ! -f "$HELPER_PLIST" ]; then
    echo -e "${RED}Error: com.collweb.AIBatteryHelper.plist not found at $HELPER_PLIST.${NC}"
    exit 1
fi

# Ensure the target directory exists
echo "Creating directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR" || {
    echo -e "${RED}Error: Failed to create directory $INSTALL_DIR.${NC}"
    exit 1
}

# Copy the AIBatteryHelper executable
echo "Copying AIBatteryHelper to $INSTALL_DIR"
cp "$HELPER_BINARY" "$INSTALL_DIR" || {
    echo -e "${RED}Error: Failed to copy AIBatteryHelper to $INSTALL_DIR.${NC}"
    exit 1
}

# Set executable permissions
echo "Setting permissions for AIBatteryHelper"
chmod 755 "$INSTALL_DIR/AIBatteryHelper" || {
    echo -e "${RED}Error: Failed to set permissions for AIBatteryHelper.${NC}"
    exit 1
}

# Copy the plist configuration file
echo "Copying plist to $LAUNCH_DAEMONS"
cp "$HELPER_PLIST" "$LAUNCH_DAEMONS" || {
    echo -e "${RED}Error: Failed to copy plist to $LAUNCH_DAEMONS.${NC}"
    exit 1
}

# Set permissions for the plist file
echo "Setting permissions for plist"
chmod 644 "$LAUNCH_DAEMONS/com.collweb.AIBatteryHelper.plist" || {
    echo -e "${RED}Error: Failed to set permissions for plist.${NC}"
    exit 1
}

# Unload the old process (to prevent conflicts)
echo "Unloading old AIBatteryHelper daemon (if exists)"
launchctl bootout system/com.collweb.AIBatteryHelper 2>/dev/null || true

# Validate plist file format
if ! plutil -lint "$LAUNCH_DAEMONS/com.collweb.AIBatteryHelper.plist" >/dev/null 2>&1; then
    echo -e "${RED}Error: Invalid plist format for $HELPER_PLIST.${NC}"
    exit 1
fi

# Register and start the daemon again
echo "Bootstrapping and starting AIBatteryHelper daemon"
launchctl bootstrap system "$LAUNCH_DAEMONS/com.collweb.AIBatteryHelper.plist" || {
    echo -e "${RED}Error: Failed to bootstrap AIBatteryHelper daemon.${NC}"
    exit 1
}

echo -e "${GREEN}AIBatteryHelper installed and started successfully.${NC}"

# Log the installation to a file (optional)
LOG_FILE="/var/log/AIBatteryHelper_install.log"
echo "Installation completed on $(date)" | tee -a "$LOG_FILE" > /dev/null
