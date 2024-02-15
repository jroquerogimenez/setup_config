#!/bin/bash

# Define your volumes to check
volumes=("/dev/nvme1n1" "/dev/nvme2n1") # Add more as needed, adjust as per your setup
mount_base="/data"
owner="ubuntu"
filesystem="xfs"

# Function to check if the volume does not have a filesystem using file -s
check_filesystem_file() {
    local volume=$1
    file_output=$(sudo file -s $volume)
    if [[ $file_output == *": data" ]]; then
        echo "No filesystem on $volume according to file -s."
        return 0 # Success, indicates no filesystem
    else
        echo "Filesystem detected on $volume according to file -s: $file_output"
        return 1 # Failure, indicates filesystem exists
    fi
}

# Function to check if the volume does not have a filesystem using lsblk -f
check_filesystem_lsblk() {
    local volume=$1
    fs_type=$(lsblk -f | grep "^$(basename $volume)" | awk '{print $2}')
    if [ -z "$fs_type" ]; then
        echo "No filesystem on $volume according to lsblk -f."
        return 0 # Success, indicates no filesystem
    else
        echo "Filesystem detected on $volume according to lsblk -f: $fs_type"
        return 1 # Failure, indicates filesystem exists
    fi
}

# Function to create and mount a filesystem
mount_volume() {
    local volume=$1
    local mount_point=$2
    echo "Creating filesystem on ${volume}."
    sudo mkfs -t $filesystem $volume
    echo "Mounting ${volume} to ${mount_point}."
    sudo mkdir -p $mount_point
    sudo mount $volume $mount_point
    echo "Changing owner of ${mount_point} to ${owner}."
    sudo chown -R $owner: $mount_point
}

# Main loop to process each volume
for i in "${!volumes[@]}"; do
    volume="${volumes[$i]}"
    # Use lsblk to ensure the volume is present
    if lsblk -f | grep -q "^$(basename $volume)"; then
        # Perform both checks
        if check_filesystem_file $volume && check_filesystem_lsblk $volume; then
            # Determine mount point
            if [ $i -eq 0 ]; then
                mount_point=$mount_base
            else
                mount_point="${mount_base}_$((i+1))"
            fi
            mount_volume $volume $mount_point
        else
            echo "Skipping $volume as it already has a filesystem or the check failed."
        fi
    else
        echo "Volume $volume not found, skipping."
    fi
done

echo "All specified volumes processed."

