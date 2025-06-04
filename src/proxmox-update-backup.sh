#!/bin/bash
# Script to update Proxmox and create compressed backups of VMs and containers

# Log file for tracking updates and backups
LOGFILE="/var/log/proxmox-update-backup.log"
BACKUP_DIR="/var/lib/vz/dump" # Default Proxmox backup directory
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

# Redirect output to log file
exec >> $LOGFILE 2>&1
echo "=== Proxmox Update and Backup started at $DATE ==="

# Step 1: Update package lists and upgrade Proxmox
echo "Updating Proxmox..."
apt update
apt full-upgrade -y
echo "Proxmox update completed."

# Step 2: Get list of all VMs and containers
VMS=$(qm list | awk 'NR>1 {print $1}') # Get VM IDs
CTS=$(pct list | awk 'NR>1 {print $1}') # Get Container IDs

# Step 3: Create compressed backups for each VM and container
echo "Starting backups..."
for ID in $VMS; do
    echo "Backing up VM ID: $ID"
    vzdump $ID --compress zstd --mode snapshot --dumpdir $BACKUP_DIR --mailto root
    if [ $? -eq 0 ]; then
        echo "Backup of VM $ID completed successfully."
    else
        echo "Backup of VM $ID failed."
    fi
done

for ID in $CTS; do
    echo "Backing up Container ID: $ID"
    vzdump $ID --compress zstd --mode snapshot --dumpdir $BACKUP_DIR --mailto root
    if [ $? -eq 0 ]; then
        echo "Backup of Container $ID completed successfully."
    else
        echo "Backup of Container $ID failed."
    fi
done



# Step 4: Clean up old backups (optional, keep last 3 backups)
echo "Cleaning up old backups (keeping last 3)..."
find $BACKUP_DIR -name "vzdump-*.tar.zst" -type f -mtime +7 -delete
echo "Backup cleanup completed."

echo "=== Proxmox Update and Backup finished at $(date '+%Y-%m-%d_%H-%M-%S') ==="