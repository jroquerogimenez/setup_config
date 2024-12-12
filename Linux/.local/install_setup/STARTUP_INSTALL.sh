#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Logging function to print messages with timestamp.
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") [LOG] $1"
}

# Function to print error messages.
error() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") [ERROR] $1" >&2
}


cp -r $HOME/setup_config/Linux/.* $HOME/

source ~/.bashrc

sudo bash $HOME/.local/install_setup/home_mount_startup.sh
sudo bash $HOME/.local/install_setup/setup_services_startup.sh
sudo bash $HOME/.local/install_setup/linux_software_startup.sh
sudo bash $HOME/.local/install_setup/python_software_startup.sh


log "Setup completed successfully."

# Need to customize scripts in ~/.local/bin: aws_mount_service_script.sh and startup_service_script.sh


# Function to set up SSH keys.
setup_ssh() {
    SSH_KEY="$HOME/.ssh/id_ed25519"
    SSH_COMMENT="RGTechMain_GitHub"
    log "Setting up SSH keys..."
    if [ -f "$SSH_KEY" ]; then
        log "SSH key already exists at $SSH_KEY."
    else
        ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$SSH_KEY" -N ""
        log "SSH key generated at $SSH_KEY."
    fi
    log "Please upload the public key to GitHub:"
}


# Function to configure Git.
configure_git() {
    GIT_USER_NAME="Jaime Roquero"
    GIT_USER_EMAIL="jaime.roquero@gmail.com"
    log "Configuring Git..."
    git config --global init.defaultBranch main
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    log "Git configured with user name and email."

    cat "$SSH_KEY.pub"
    read -p "Press enter after uploading the SSH key to GitHub..."
    log "Attempting to connect to GitHub via SSH..."
    ssh -T git@github.com || true
}

# Function to configure AWS CLI.
configure_aws_cli() {
    log "Configuring AWS CLI..."
    aws configure
    log "AWS credentials stored in $HOME/.aws/credentials."
}

sudo mkdir -p /data/jaimemain
s3fs jaimemain /data/jaimemain

sudo chown -R $USER /usr/local/