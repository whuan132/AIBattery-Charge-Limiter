#!/bin/bash

# Set the script to exit immediately on failure
set -e

# Color codes for log output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Uninstalling AIBatteryHelper...${NC}"

# Check if the user has sudo privileges
if ! sudo -l >/dev/null 2>&1; then
    echo -e "${RED}Error: This script requires sudo privileges. Please run with sudo.${NC}"
    exit 1
fi

# Define paths
INSTALL_DIR="/Library/Application Support/AIBatteryHelper/"
PLIST_PATH="/Library/LaunchDaemons/com.collweb.AIBatteryHelper.plist"
LOG_FILE="/var/log/AIBatteryHelper_install.log"

# Stop the daemon process
echo "Stopping AIBatteryHelper daemon..."
sudo launchctl bootout system/com.collweb.AIBatteryHelper 2>/dev/null || {
    echo "No running AIBatteryHelper daemon found, skipping..."
}

# Check and remove the plist file
if [ -f "$PLIST_PATH" ]; then
    echo "Removing plist file: $PLIST_PATH"
    sudo rm "$PLIST_PATH" || {
        echo -e "${RED}Error: Failed to remove plist file $PLIST_PATH.${NC}"
        exit 1
    }
else
    echo "Plist file not found, skipping..."
fi

# Check and remove the installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing AIBatteryHelper directory: $INSTALL_DIR"
    sudo rm -rf "$INSTALL_DIR" || {
        echo -e "${RED}Error: Failed to remove directory $INSTALL_DIR.${NC}"
        exit 1
    }
else
    echo "Installation directory not found, skipping..."
fi

# Check and remove the possible log file
if [ -f "$LOG_FILE" ]; then
    echo "Removing installation log: $LOG_FILE"
    sudo rm "$LOG_FILE" || {
        echo -e "${RED}Warning: Failed to remove log file $LOG_FILE, continuing...${NC}"
    }
else
    echo "Installation log not found, skipping..."
fi

echo -e "${GREEN}AIBatteryHelper uninstalled successfully.${NC}"

# Log the uninstallation process to a file
UNINSTALL_LOG="/var/log/AIBatteryHelper_uninstall.log"
echo "Uninstallation completed on $(date)" | sudo tee -a "$UNINSTALL_LOG" > /dev/null
