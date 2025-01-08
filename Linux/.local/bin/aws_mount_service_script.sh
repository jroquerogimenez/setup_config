#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Configuration
volumes=("/dev/nvme2n1" "/dev/nvme3n1" "/dev/nvme1n1") # Adjust as per your setup / nvme1n1 already mounted in home.
mount_base="/data"
owner="ubuntu"
filesystem="xfs"
LOG_FILE="/var/log/volume_mount.log"

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Redirect all output and errors to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Start of the script
log "===== Starting mount service Script ====="

# Validate inputs
if [ -z "$mount_base" ]; then
    log "Error: mount_base is not defined. Exiting."
    exit 1
fi

if [ ! -d "$mount_base" ]; then
    log "Creating base mount directory: $mount_base"
    if ! sudo mkdir -p "$mount_base"; then
        log "Error: Failed to create mount_base directory. Exiting."
        exit 1
    fi
fi

# Function to check if a volume is already mounted
check_if_mounted() {
    local volume=$1
    local mnt_point

    # Extract the mount point if the volume is mounted
    mnt_point=$(mount | awk -v vol="$volume" '$1 == vol {print $3}')
    
    if [ -n "$mnt_point" ]; then
        log "Error: Volume $volume is already mounted on $mnt_point. Skipping."
        return 1
    fi
    return 0
}

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

# Function to create and mount a filesystem
mount_volume() {
    local volume=$1
    local mount_point=$2
    log "Mounting $volume to $mount_point."
    if ! sudo mkdir -p "$mount_point"; then
        log "Error: Failed to create mount point $mount_point."
        return 1
    fi

    if ! sudo mount "$volume" "$mount_point"; then
        log "Error: Failed to mount $volume to $mount_point."
        return 1
    fi

    log "Changing owner of $mount_point to $owner."
    if ! sudo chown -R "$owner:" "$mount_point"; then
        log "Error: Failed to change ownership of $mount_point."
        return 1
    fi
    return 0
}

# Main loop to process each volume
for volume in "${volumes[@]}"; do
    device_name=$(basename "$volume")
    mount_point="${mount_base}/${device_name}"

    log "Processing volume: $volume"

    # Ensure the volume exists
    if ! lsblk -no NAME "$volume" > /dev/null 2>&1; then
        log "Error: Volume $volume not found. Skipping."
        continue
    fi

    # Check if the volume is already mounted
    if ! check_if_mounted "$volume"; then
        continue
    fi

    # Check for existing filesystem
    if check_filesystem_file "$volume" && check_filesystem_lsblk "$volume"; then
        log "Creating filesystem on $volume."
        if ! sudo mkfs -t "$filesystem" "$volume"; then
            log "Error: Failed to create filesystem on $volume. Skipping."
            continue
        fi
    fi

    # Mount the volume
    if ! mount_volume "$volume" "$mount_point"; then
        log "Error: Failed to mount $volume. Skipping."
        continue
    fi
done

log "===== All specified volumes processed. Script completed. ====="
