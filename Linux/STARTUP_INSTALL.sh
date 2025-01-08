#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Logging function to print messages with timestamp.
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") [LOG] $1"
}


mv $HOME/setup_config/Linux/.* $HOME/
mv $HOME/setup_config/python_project/vscode $HOME/setup_config/python_project/.vscode

source ~/.bashrc

sudo bash $HOME/.local/install_setup/home_mount_startup.sh
sudo bash $HOME/.local/install_setup/setup_services_startup.sh
sudo bash $HOME/.local/install_setup/linux_software_startup.sh
bash $HOME/.local/install_setup/python_software_startup.sh


log "Setup completed successfully."


# Need to customize scripts in ~/.local/bin: aws_mount_service_script.sh and startup_service_script.sh

 
# Install docker


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

# sudo mkdir -p /data/jaimemain
# s3fs jaimemain /data/jaimemain

# sudo chown -R $USER /usr/local/