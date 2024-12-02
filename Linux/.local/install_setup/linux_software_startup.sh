#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Redirect output to a log file.
exec > >(tee -i install.log)
exec 2>&1

# Check for root privileges.
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Ensure non-interactive installation.
export DEBIAN_FRONTEND=noninteractive

# Update package lists and upgrade installed packages.
echo "Updating package lists and upgrading installed packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages.
echo "Installing essential packages..."

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
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean -y

# Optionally, remove apt lists to save space (not recommended on regular systems)
# sudo rm -rf /var/lib/apt/lists/*

echo "Installation completed successfully."
