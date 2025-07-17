#!/bin/bash -
# File:        serve_nodejs.sh
# Author:      Christo Deale 
# Date:        2025-07-17
# Version:     1.2.0
# Description: Install Node.js and serve a directory using the serve package.

# Check if Development Tools are installed
if ! rpm -q '@development-tools' &> /dev/null; then
    sudo dnf groupinstall 'Development Tools' -y
fi

# Identify the latest version of nodejs
latest_node_version=$(dnf module list nodejs | grep -E '^nodejs' | awk '{print $2}' | sort -rV | head -n 1)

# Enable and install the latest version of nodejs
sudo dnf module -y enable nodejs:$latest_node_version
sudo dnf module -y install nodejs:$latest_node_version

# Verify the installation
node -v
npm -v

# Install serve
npm install -g serve

# Ask for user input
read -p "Enter the port to serve: " port
read -p "Enter the directory path to serve (default: /home/user): " directory
directory=${directory:-/home/user}

# Start serving
serve -p $port $directory
