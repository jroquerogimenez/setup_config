## Not working: commented the mkfs line just in case.




#!/bin/bash

# Define your volumes to check
volumes=("/dev/nvme1n1" "/dev/nvme2n1") # Add more as needed
mount_base="/data"
owner="ubuntu"
filesystem="xfs"

# Function to create and mount a filesystem
mount_volume() {
    local volume=$1
    local mount_point=$2
    echo "Creating filesystem on ${volume}."
#    sudo mkfs -t $filesystem $volume
    echo "Mounting ${volume} to ${mount_point}."
    sudo mkdir -p $mount_point
    sudo mount $volume $mount_point
    echo "Changing owner of ${mount_point} to ${owner}."
    sudo chown -R $owner: $mount_point
}

# Main loop to process each volume
for i in "${!volumes[@]}"; do
    volume="${volumes[$i]}"
    # Check if volume is present and does not have a filesystem
    if lsblk -f | grep -q "^$(basename $volume)"; then
        fs_type=$(lsblk -f | grep "^$(basename $volume)" | awk '{print $2}')
        if [ -z "$fs_type" ]; then
            # Determine mount point (e.g., /data for the first, /data_2 for the second, etc.)
            if [ $i -eq 0 ]; then
                mount_point=$mount_base
            else
                mount_point="${mount_base}_$((i+1))"
            fi
            mount_volume $volume $mount_point
        else
            echo "Volume ${volume} already has a filesystem ($fs_type), skipping."
        fi
    else
        echo "Volume ${volume} not found, skipping."
    fi
done

echo "All specified volumes processed."

