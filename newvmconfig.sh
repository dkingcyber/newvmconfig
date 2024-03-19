#!/bin/bash

# Ensure the script is run with superuser privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Function to validate IP addresses
validate_ip() {
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        echo "Invalid IP address format: $1"
        return 1
    fi
}

# Change the hostname
read -p "Do you wish to change the hostname? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter the new hostname: " new_hostname
    # Backup /etc/hostname before changing
    cp /etc/hostname /etc/hostname.backup
    echo $new_hostname > /etc/hostname
    # Backup /etc/hosts before editing
    cp /etc/hosts /etc/hosts.backup
    sed -i "/127.0.1.1/s/.*/127.0.1.1\t$new_hostname/" /etc/hosts
    echo "The new hostname is: $new_hostname"
    echo "You may need to restart or log out & log in for the changes to fully take effect."
fi

# Change the IP address
read -p "Do you wish to change the IP address? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter the new IP address: " new_ip
    read -p "Enter the new netmask: " new_netmask
    read -p "Enter the new gateway: " new_gateway
    read -p "Enter the new DNS server: " new_dns

    # Validate IP address and netmask
    validate_ip $new_ip
    valid_ip=$?
    validate_ip $new_netmask
    valid_netmask=$?
    validate_ip $new_gateway
    valid_gateway=$?
    validate_ip $new_dns
    valid_dns=$?

    if [[ $valid_ip -eq 0 && $valid_netmask -eq 0 && $valid_gateway -eq 0 && $valid_dns -eq 0 ]]; then
        # Backup /etc/network/interfaces before editing
        cp /etc/network/interfaces /etc/network/interfaces.backup
        sed -i "/iface eth0 inet static/s/.*/iface eth0 inet static\n\taddress $new_ip\n\tnetmask $new_netmask\n\tgateway $new_gateway\n\tdns-nameservers $new_dns/" /etc/network/interfaces
        echo "The new IP configuration is set."
        echo "You may need to restart the networking service for the changes to take effect."
    else
        echo "One or more provided values are in an incorrect format. No changes made."
    fi
fi

# Disable ssh to root
read -p "Would you like to disable ssh to root? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup /etc/ssh/sshd_config before editing
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    sed -i "/PermitRootLogin/s/.*/PermitRootLogin no/" /etc/ssh/sshd_config
    echo "SSH root access disabled."
    echo "You may need to restart the SSH service for the changes to take effect."
fi

# System reboot
read -p "Do you wish to reboot the system now? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
else
    echo "Please remember to reboot the system later to apply all changes."
fi
