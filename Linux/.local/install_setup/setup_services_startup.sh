#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# This script sets up systemd services for aws_mount_script.sh and startup_script.sh.
# It replaces placeholders in service templates, moves them to the systemd directory,
# sets appropriate permissions, and enables the services to run at boot.

# Variables
HOME_DIR="/home/ubuntu"
SYSTEMD_DIR="/etc/systemd/system"
LOG_FILE="/var/log/setup_services.log"

# Scripts and Service Files
STARTUP_SCRIPT="$HOME_DIR/.local/bin/startup_service_script.sh"
AWS_MOUNT_SCRIPT="$HOME_DIR/.local/bin/aws_mount_service_script.sh"
STARTUP_SERVICE_TEMPLATE="$HOME_DIR/.local/systemd_files/startup_script.service.template"
AWS_MOUNT_SERVICE_TEMPLATE="$HOME_DIR/.local/systemd_files/aws_mount_script.service.template"
STARTUP_SERVICE="$HOME_DIR/.local/systemd_files/startup_script.service"
AWS_MOUNT_SERVICE="$HOME_DIR/.local/systemd_files/aws_mount_script.service"

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Redirect all output and errors to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Start of the script
log "===== Starting Systemd services install Script ====="

# Function to check if a service exists
service_exists() {
    local service_name=$1
    if systemctl list-unit-files | grep -q "^${service_name}"; then
        log "Service ${service_name} already exists."
        return 0
    else
        return 1
    fi
}

# Check if startup_script.service exists
if service_exists "startup_script.service"; then
    log "startup_script.service already exists. Exiting script."
    exit 0
fi

# Check if aws_mount_script.service exists
if service_exists "aws_mount_script.service"; then
    log "aws_mount_script.service already exists. Exiting script."
    exit 0
fi

# Replace placeholders in service templates
log "Replacing placeholders in service templates..."

sed "s|{SCRIPT_PATH}|$STARTUP_SCRIPT|" "$STARTUP_SERVICE_TEMPLATE" > "$STARTUP_SERVICE"
sed "s|{SCRIPT_PATH}|$AWS_MOUNT_SCRIPT|" "$AWS_MOUNT_SERVICE_TEMPLATE" > "$AWS_MOUNT_SERVICE"

# Move service files to systemd directory
log "Moving service files to $SYSTEMD_DIR..."
sudo mv "$STARTUP_SERVICE" "$SYSTEMD_DIR/"
sudo mv "$AWS_MOUNT_SERVICE" "$SYSTEMD_DIR/"


# To delete, once check that running services with user ubuntu works.
# # Set ownership and permissions on the scripts
# log "Setting ownership and permissions on scripts..."
# sudo chown root:root "$STARTUP_SCRIPT"
# sudo chown root:root "$AWS_MOUNT_SCRIPT"
# sudo chmod 700 "$STARTUP_SCRIPT"
# sudo chmod 700 "$AWS_MOUNT_SCRIPT"

chmod u+x "$STARTUP_SCRIPT"
chmod u+x "$AWS_MOUNT_SCRIPT"

# Reload systemd daemon
log "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable services to run at boot
log "Enabling services to run at boot..."
sudo systemctl enable startup_script.service
sudo systemctl enable aws_mount_script.service

# Start of the script
log "===== Systemd services completed successfully. ====="
