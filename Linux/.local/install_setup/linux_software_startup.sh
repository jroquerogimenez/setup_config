#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Variables
LOG_FILE="/var/log/linux_software_install.log"






# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Redirect all output and errors to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Start of the script
log "===== Starting Linux Software install Script ====="

# Check for root privileges.
if [ "$EUID" -ne 0 ]; then
  log "Please run as root."
  exit 1
fi

# Ensure non-interactive installation.
export DEBIAN_FRONTEND=noninteractive

# Update package lists and upgrade installed packages.
log "Updating package lists and upgrading installed packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages.
log "Installing essential packages..."

# Development tools
sudo apt install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    gcc \
    g++ \
    gfortran \
    llvm \
    bison \
    byacc

# Version control
sudo apt install -y --no-install-recommends \
    git \
    rsync

# Programming languages and runtimes
sudo apt install -y --no-install-recommends \
    default-jdk \
    default-jre \
    python3-dev \
    littler

# Libraries
sudo apt install -y --no-install-recommends \
    libbz2-dev \
    libboost-all-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    liblzma-dev \
    libncurses5-dev \
    libpcre2-dev \
    libreadline-dev \
    libreadline8 \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libz-dev \
    zlib1g-dev \
    tk-dev

# System utilities
sudo apt install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common \
    locales \
    wget \
    unzip \
    gzip \
    xz-utils \
    nano \
    vim \
    less \
    ssh \
    procps \
    s3fs \
    ed \
    gnupg1 \
    gnupg2

# Visualization tools
sudo apt install -y --no-install-recommends \
    graphviz

# Clean up
log "Cleaning up..."
sudo apt autoremove -y
sudo apt clean -y

# Optionally, remove apt lists to save space (not recommended on regular systems)
# sudo rm -rf /var/lib/apt/lists/*

log "===== Linux Software install completed successfully. ====="
