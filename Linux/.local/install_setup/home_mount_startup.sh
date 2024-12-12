#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Variables
DEVICE="/dev/nvme1n1"
MOUNT_POINT="/home/ubuntu"

TEMP_DIR="/tmp/ubuntu_home_backup"
FSTAB_FILE="/etc/fstab"
LOG_FILE="/var/log/ebs_mount.log"

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Redirect all output and errors to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Start of the script
log "===== Starting EBS Mount Script ====="

# Function to check if the volume does not have a filesystem using file -s
check_filesystem_file() {
    local volume=$1
    file_output=$(sudo file -s "$volume")
    if [[ $file_output == *": data" ]]; then
        log "No filesystem on $volume according to file -s."
        return 0 # Success, indicates no filesystem
    else
        log "Filesystem detected on $volume according to file -s: $file_output"
        return 1 # Failure, indicates filesystem exists
    fi
}

# Function to check if the volume does not have a filesystem using lsblk -f
check_filesystem_lsblk() {
    local volume=$1
    fs_type=$(lsblk -no FSTYPE "$volume")
    if [ -z "$fs_type" ]; then
        log "No filesystem on $volume according to lsblk."
        return 0 # Success, indicates no filesystem
    else
        log "Filesystem detected on $volume according to lsblk: $fs_type"
        return 1 # Failure, indicates filesystem exists
    fi
}

# Step 0: Check if the DEVICE corresponds to an attached volume.
if ! lsblk | grep -q "$DEVICE"; then
    log "$DEVICE not found. Exiting script"
    exit 1
fi

# Step 1: Check if the DEVICE already has a filesystem
log "Checking if $DEVICE already has a filesystem..."

if check_filesystem_file "$DEVICE" && check_filesystem_lsblk "$DEVICE"; then
    log "No filesystem found on $DEVICE. Proceeding to create filesystem."
else
    log "Filesystem already exists on $DEVICE. Exiting script."
    exit 0
fi

# Step 2: Create Filesystem on the EBS Volume
log "Creating XFS filesystem on $DEVICE..."
sudo mkfs -t xfs $DEVICE

# Step 3: Get the UUID of the EBS Volume
log "Retrieving UUID of the device..."
UUID=$(sudo blkid -s UUID -o value $DEVICE)
log "UUID is $UUID"

# Step 4: Backup Existing /home/ubuntu Directory
log "Backing up existing $MOUNT_POINT to $TEMP_DIR..."
sudo rsync -a $MOUNT_POINT/ $TEMP_DIR/

# Step 5: Add Entry to /etc/fstab
log "Updating /etc/fstab..."
FSTAB_ENTRY="UUID=$UUID   $MOUNT_POINT   xfs   defaults,nofail   0   2"
log "Adding the following line to $FSTAB_FILE:"
log "$FSTAB_ENTRY"
echo "$FSTAB_ENTRY" | sudo tee -a $FSTAB_FILE

# Step 6: Test /etc/fstab Configuration
log "Testing /etc/fstab configuration..."
if sudo mount -a; then
    if mountpoint -q $MOUNT_POINT; then
        log "Mount successful."
    else
        log "Mount failed. Restoring original /etc/fstab."
        sudo sed -i '$ d' $FSTAB_FILE  # Remove the last line added
        exit 1
    fi
else
    log "Mount command failed. Restoring original /etc/fstab."
    sudo sed -i '$ d' $FSTAB_FILE
    exit 1
fi

# Step 7: Restore Data to /home/ubuntu
log "Restoring data to $MOUNT_POINT..."
sudo rsync -a $TEMP_DIR/ $MOUNT_POINT/

# Step 8: Set Correct Permissions
log "Setting correct permissions for $MOUNT_POINT..."
sudo chown -R ubuntu:ubuntu $MOUNT_POINT
sudo chmod 755 $MOUNT_POINT

# Step 9: Clean Up Temporary Backup
log "Cleaning up temporary backup..."
sudo rm -rf $TEMP_DIR

log "===== EBS Mount Script Completed Successfully ====="
