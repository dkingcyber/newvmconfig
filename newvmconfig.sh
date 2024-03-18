#!/bin/bash

# Backup /etc/hostname and /etc/hosts
cp /etc/hostname /etc/hostname.bak
cp /etc/hosts /etc/hosts.bak

# Get new hostname from user
echo "Enter the new hostname for the VM: "
read newhostname

# Validate the hostname
if [[ "$newhostname" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    # Edit the /etc/hostname file
    echo $newhostname > /etc/hostname

    # Edit the /etc/hosts file, more carefully
    sed -i "/127.0.1.1/s/.*/127.0.1.1\t$newhostname/" /etc/hosts

    # Warning before rebooting
    echo "The system will now reboot to apply changes."
    sleep 3
    reboot
else
    echo "Invalid hostname. Please use alphanumeric characters, dashes, or underscores only."
    # Restore from backup due to invalid input
    cp /etc/hostname.bak /etc/hostname
    cp /etc/hosts.bak /etc/hosts
fi
