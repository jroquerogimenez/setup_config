#!/bin/bash

# This script sets up systemd services for aws_mount_script.sh and startup_script.sh.
# It replaces placeholders in service templates, moves them to the systemd directory,
# sets appropriate permissions, and enables the services to run at boot.

# Variables
HOME_DIR="$HOME"
SETUP_DIR="$HOME_DIR/setup_config/Linux/.local/systemd_files"
SYSTEMD_DIR="/etc/systemd/system"
LOG_FILE="$HOME_DIR/setup_config/setup_services.log"

# Scripts and Service Files
STARTUP_SCRIPT="$HOME_DIR/.local/bin/startup_service_script.sh"
AWS_MOUNT_SCRIPT="$HOME_DIR/.local/bin/aws_mount_service_script.sh"
STARTUP_SERVICE_TEMPLATE="$SETUP_DIR/startup_script.service.template"
AWS_MOUNT_SERVICE_TEMPLATE="$SETUP_DIR/aws_mount_script.service.template"
STARTUP_SERVICE="$SETUP_DIR/startup_script.service"
AWS_MOUNT_SERVICE="$SETUP_DIR/aws_mount_script.service"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Script started at $(date)"

# Function to check if a service exists
service_exists() {
    local service_name=$1
    if systemctl list-unit-files | grep -q "^${service_name}"; then
        echo "Service ${service_name} already exists."
        return 0
    else
        return 1
    fi
}

# Check if startup_script.service exists
if service_exists "startup_script.service"; then
    echo "startup_script.service already exists. Exiting script."
    exit 0
fi

# Check if aws_mount_script.service exists
if service_exists "aws_mount_script.service"; then
    echo "aws_mount_script.service already exists. Exiting script."
    exit 0
fi

# Replace placeholders in service templates
echo "Replacing placeholders in service templates..."

sed "s|{SCRIPT_PATH}|$STARTUP_SCRIPT|" "$STARTUP_SERVICE_TEMPLATE" > "$STARTUP_SERVICE"
sed "s|{SCRIPT_PATH}|$AWS_MOUNT_SCRIPT|" "$AWS_MOUNT_SERVICE_TEMPLATE" > "$AWS_MOUNT_SERVICE"

# Move service files to systemd directory
echo "Moving service files to $SYSTEMD_DIR..."
sudo mv "$STARTUP_SERVICE" "$SYSTEMD_DIR/"
sudo mv "$AWS_MOUNT_SERVICE" "$SYSTEMD_DIR/"

# Set ownership and permissions on the scripts
echo "Setting ownership and permissions on scripts..."
sudo chown root:root "$STARTUP_SCRIPT"
sudo chown root:root "$AWS_MOUNT_SCRIPT"
sudo chmod 700 "$STARTUP_SCRIPT"
sudo chmod 700 "$AWS_MOUNT_SCRIPT"

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable services to run at boot
echo "Enabling services to run at boot..."
sudo systemctl enable startup_script.service
sudo systemctl enable aws_mount_script.service

echo "Services have been set up successfully. Script completed at $(date)"
