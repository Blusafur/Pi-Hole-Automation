#!/bin/bash

# Prerequisites for install
# 1. Verify static IP addressing on interface you want to use
# 2. Verify internet connectivity on raspberry pi
# 3. Change default password for pi user
# Optional - LCD screen is working if using one
# Optional - Enable SSH access

# Variables for script, set to TRUE or FALSE
# Check for updates/upgrades for packages/OS before starting install
UPDATE=TRUE
# Enable reboot and specify time by the hour (24 hour)
REBOOTSCHEDULED=TRUE
REBOOTTIME=4
# Set temperature to fahrenheit instead of celsius
TEMPF=TRUE
# Install PADD (https://github.com/pi-hole/PADD)
PADD=TRUE
# Set to auto login on terminal (No GUI)
BOOTTERMINAL=TRUE
# Add commands to the .bashrc file to create a pihole backup, do updates, and start PADD (this file runs automatically when a terminal opens)
BASHRC=TRUE

# Start in Pi's home directory
cd /home/pi

# Check for updates/upgrades for packages/OS before starting install if wanted
if [ "$UPDATE" = "TRUE" ]
then
	apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y
fi

# Install Pi-Hole (https://docs.pi-hole.net/main/basic-install/)
curl -sSL https://install.pi-hole.net | bash

# Download PADD if wanted
if [ "$PADD" = "TRUE" ]
then
	wget -N https://raw.githubusercontent.com/pi-hole/PADD/master/padd.sh
	chmod +x padd.sh
fi

# Install scheduled reboot to crontab if wanted
if [ "$REBOOTSCHEDULED" = "TRUE" ]
then
	(sudo crontab -l ; echo "0 $REBOOTTIME * * * /sbin/shutdown -r now")| sudo crontab -
fi

# Set temperature to fahrenheit instead of celsius if wanted
if [ "$TEMPF" = "TRUE" ]
then
	echo "TEMPERATUREUNIT=F" | sudo tee -a /etc/pihole/setupVars.conf
fi

# Set system to boot to terminal and autologin if wanted
if [ "$BOOTTERMINAL" = "TRUE" ]
then
	raspi-config nonint do_boot_behaviour B2
fi

# Add commands to the .bashrc file to create a pihole backup, do updates, and start PADD if wanted
if [ "$BASHRC" = "TRUE" ]
then
	cat /home/pi/Pi-Hole-Automation/BASHAPPEND | sudo tee -a /home/pi/.bashrc
fi
