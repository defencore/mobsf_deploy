#!/bin/bash

# This script performs the following actions:
# 1. Updates and upgrades the system packages.
# 2. Installs necessary packages: unzip and docker.io.
# 3. Downloads and installs the latest version of APKTOOL.
# 4. Downloads and installs the latest version of JADX (Dex to Java Decompiler).
# 5. Downloads and installs the latest version of Docker Compose.

sudo apt-get update
sudo apt-get upgrade -y

PLATFORM=$(uname -m)
OS=$(uname -s | awk '{print tolower($0)}')

sudo apt-get install unzip docker.io -y

# APKTOOL latest version
sudo rm -rf /usr/local/bin/apktool /usr/local/bin/apktool.jar
APKTOOL_URL=$(curl -s https://bitbucket.org/iBotPeaches/apktool/downloads/  | grep -oP 'href="\K(.*?apktool_[^"]*\.jar)' | head -n 1)
sudo curl -Lo /usr/local/bin/apktool.jar https://bitbucket.org$APKTOOL_URL
sudo chmod +r /usr/local/bin/apktool.jar
sudo curl -Lo /usr/local/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
sudo chmod +x /usr/local/bin/apktool

# JADX - Dex to Java Decompiler
sudo rm -rf /usr/local/bin/jadx /opt/jadx
JADX_VERSION=$(curl -s "https://api.github.com/repos/skylot/jadx/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo jadx.zip "https://github.com/skylot/jadx/releases/latest/download/jadx-${JADX_VERSION}.zip"
unzip jadx.zip -d jadx-temp
sudo mkdir -p /opt/jadx/bin
sudo mv jadx-temp/bin/jadx /opt/jadx/bin
sudo mv jadx-temp/bin/jadx-gui /opt/jadx/bin
sudo mv jadx-temp/lib /opt/jadx
rm -rf jadx.zip jadx-temp
sudo ln -s /opt/jadx/bin/jadx /usr/local/bin/jadx

# Docker Compose
sudo rm -rf /usr/local/bin/docker-compose
COMPOSE_VERSION=$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-${OS}-${PLATFORM}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

sudo docker build -f Dockerfile -t mobsf_a .

# HowTo
# - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04
