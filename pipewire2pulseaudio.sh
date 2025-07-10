#!/bin/sh -
# File:        pipewire2pulseaudio.sh
# Author:      Christo Deale 
# Date:        2025-07-10
# Version:     1.0.0
# Description: This script switches the audio system from PipeWire to PulseAudio on a Fedora-based system.
#
# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Execute the necessary commands
echo "Swapping pipewire-pulseaudio with pulseaudio..."
dnf swap --allowerasing pipewire-pulseaudio pulseaudio

echo "Removing pipewire-alsa and pipewire-jack-audio-connection-kit..."
dnf remove pipewire-alsa pipewire-jack-audio-connection-kit

echo "Installing alsa-plugins-pulseaudio..."
dnf install alsa-plugins-pulseaudio

echo "Enabling pulseaudio service globally..."
systemctl --global enable pulseaudio.service

# Prompt user for reboot
read -p "Do you want to reboot now? (y/n): " REBOOT

if [ "$REBOOT" == "y" ]; then
  echo "Rebooting system..."
  reboot
else
  echo "Reboot canceled. Exiting program."
fi
