#!/bin/bash

# This script performs the following actions:
# 1. Updates and upgrades the system packages.
# 2. Installs necessary packages: unzip and docker.io.
# 3. Downloads and installs the latest version of APKTOOL.
# 4. Downloads and installs the latest version of JADX (Dex to Java Decompiler).
# 5. Downloads and installs the latest version of Docker Compose.

# Update the system package list
sudo apt-get update

# Upgrade all installed packages to their latest versions
sudo apt-get upgrade -y

# Detect the platform architecture (e.g., x86_64) and operating system (e.g., linux)
PLATFORM=$(uname -m)
OS=$(uname -s | awk '{print tolower($0)}')

# Install unzip and docker.io (Docker engine)
sudo apt-get install unzip docker.io -y

# APKTOOL latest version installation

# Remove any previous APKTOOL versions from the system
sudo rm -rf /usr/local/bin/apktool /usr/local/bin/apktool.jar

# Fetch the latest APKTOOL jar file URL and download it
APKTOOL_URL=$(curl -s https://bitbucket.org/iBotPeaches/apktool/downloads/  | grep -oP 'href="\K(.*?apktool_[^"]*\.jar)' | head -n 1)
sudo curl -Lo /usr/local/bin/apktool.jar https://bitbucket.org$APKTOOL_URL

# Set the necessary permissions for the APKTOOL jar file
sudo chmod +r /usr/local/bin/apktool.jar

# Download the APKTOOL shell script and make it executable
sudo curl -Lo /usr/local/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
sudo chmod +x /usr/local/bin/apktool

# JADX - Dex to Java Decompiler installation

# Remove any previous JADX installations
sudo rm -rf /usr/local/bin/jadx /opt/jadx

# Fetch the latest JADX version from the GitHub API
JADX_VERSION=$(curl -s "https://api.github.com/repos/skylot/jadx/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

# Download and unzip the JADX package
curl -Lo jadx.zip "https://github.com/skylot/jadx/releases/latest/download/jadx-${JADX_VERSION}.zip"
unzip jadx.zip -d jadx-temp

# Move JADX binaries and libraries to the /opt/jadx directory
sudo mkdir -p /opt/jadx/bin
sudo mv jadx-temp/bin/jadx /opt/jadx/bin
sudo mv jadx-temp/bin/jadx-gui /opt/jadx/bin
sudo mv jadx-temp/lib /opt/jadx

# Clean up temporary files
rm -rf jadx.zip jadx-temp

# Create a symbolic link to JADX in /usr/local/bin for easier access
sudo ln -s /opt/jadx/bin/jadx /usr/local/bin/jadx

# Docker Compose installation

# Remove any previous Docker Compose versions
sudo rm -rf /usr/local/bin/docker-compose

# Fetch the latest Docker Compose version from the GitHub API
COMPOSE_VERSION=$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

# Download Docker Compose binary and place it in /usr/local/bin
sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-${OS}-${PLATFORM}" -o /usr/local/bin/docker-compose

# Make the Docker Compose binary executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify the installed Docker Compose version
docker-compose --version

# Add the current user to the Docker group to allow Docker commands without sudo
sudo usermod -aG docker ubuntu

# Restart the Docker service to apply the group changes
sudo systemctl restart docker

# Refresh group membership for the current session to apply the Docker group
newgrp docker

# HowTo
# For additional guidance on Docker Compose installation and usage:
# - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04
