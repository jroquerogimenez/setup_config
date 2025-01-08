#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail


# Variables
LOG_FILE="/var/log/python_software_install.log"

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Redirect all output and errors to the log file
exec > >(sudo tee -a "$LOG_FILE") 2>&1

# Start of the script
log "===== Starting Python Software install Script ====="

# Function to install pyenv.
install_pyenv() {
    log "Installing pyenv..."
    if command -v pyenv >/dev/null 2>&1; then
        log "pyenv is already installed."
    else
        curl https://pyenv.run | bash

        # # Update shell configuration.
        # echo -e '\n# Pyenv configuration' >> ~/.bashrc
        # echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        # echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        # echo 'eval "$(pyenv init -)"' >> ~/.bashrc

        # Source the updated .bashrc.
        source /home/ubuntu/.bashrc
        log "pyenv installed and shell configuration updated."
    fi
}

# Function to install a specific Python version using pyenv.
install_python() {
    PYTHON_VERSION=3.12.7
    source /home/ubuntu/.bashrc
    log "Installing Python $PYTHON_VERSION using pyenv..."
    if ~/.pyenv/bin/pyenv versions | grep -q $PYTHON_VERSION; then
        log "Python $PYTHON_VERSION is already installed."
    else
        ~/.pyenv/bin/pyenv install $PYTHON_VERSION
        log "Python $PYTHON_VERSION installed."
    fi
    ~/.pyenv/bin/pyenv global $PYTHON_VERSION
    log "Python $PYTHON_VERSION set as global version."
}

# Function to install Poetry.
install_poetry() {
    POETRY_VERSION=1.8.0
    log "Installing Poetry version $POETRY_VERSION..."
    if command -v poetry >/dev/null 2>&1; then
        log "Poetry is already installed."
    else
        curl -sSL https://install.python-poetry.org | POETRY_VERSION=$POETRY_VERSION $HOME/.pyenv/shims/python - --yes

        # # Update PATH for the current session and future sessions.
        # echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        # export PATH="$HOME/.local/bin:$PATH"
        log "Poetry installed."
    fi
    ~/.local/bin/poetry config virtualenvs.in-project true
    log "Poetry configured to create virtual environments in the project directory."
}

# Function to install AWS CLI.
install_aws_cli() {
    log "Installing AWS CLI..."
    if command -v aws >/dev/null 2>&1; then
        log "AWS CLI is already installed."
    else
        mkdir -p $HOME/.local/tmp
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/.local/tmp/awscliv2.zip"
        unzip "$HOME/.local/tmp/awscliv2.zip" -d "$HOME/.local/tmp/"
        $HOME/.local/tmp/aws/install --install-dir $HOME/.local/lib/ --bin-dir $HOME/.local/bin/
        rm -rf $HOME/.local/tmp/aws "$HOME/.local/tmp/awscliv2.zip"

        # # Update PATH for the current session and future sessions.
        # echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        # export PATH="$HOME/.local/bin:$PATH"
        log "AWS CLI installed."
    fi
}

# Function to prepare the mount point for AWS S3.
prepare_mount_point() {
    MOUNT_POINT="/data"
    log "Preparing mount point at $MOUNT_POINT..."
    if [ ! -d "$MOUNT_POINT" ]; then
        sudo mkdir -p "$MOUNT_POINT"
        sudo chown -R "$USER" "$MOUNT_POINT"
        log "Mount point $MOUNT_POINT created and ownership set to $USER."
    else
        log "Mount point $MOUNT_POINT already exists."
    fi
}

# Function to generate an SSL certificate for Jupyter notebooks.
generate_ssl_certificate() {
    SSL_DIR="$HOME/.ssl"
    SSL_KEY="$SSL_DIR/mykey.key"
    SSL_CERT="$SSL_DIR/mycert.pem"
    OPENSSL_CONFIG="$SSL_DIR/openssl.cnf"
    log "Generating SSL certificate for Jupyter notebooks..."
    mkdir -p "$SSL_DIR"
    if [ -f "$SSL_KEY" ] && [ -f "$SSL_CERT" ]; then
        log "SSL certificate and key already exist in $SSL_DIR."
    else
        if [ ! -f "$OPENSSL_CONFIG" ]; then
            log "Creating default openssl.cnf in $SSL_DIR..."
            cat > "$OPENSSL_CONFIG" <<EOF
[req]
prompt = no
distinguished_name = dn

[dn]
CN = localhost
EOF
        fi
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$SSL_KEY" -out "$SSL_CERT" -config "$OPENSSL_CONFIG"
        chmod 600 "$SSL_KEY"
        log "SSL certificate and key generated in $SSL_DIR."
    fi
}

# Function to install VSCode extensions.
install_vscode_extensions() {
    EXTENSIONS_FILE="$HOME/.vscode/extensions.txt"
    log "Installing VSCode extensions..."
    if [ -f "$EXTENSIONS_FILE" ]; then
        xargs -I {} code --install-extension {} < "$EXTENSIONS_FILE"
        log "VSCode extensions installed."
    else
        log "VSCode extensions list not found at $EXTENSIONS_FILE."
    fi
}

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


# Function to install Docker
install_docker() {
    log "Starting Docker installation process..."

    # Check if Docker is already installed
    if command -v docker >/dev/null 2>&1; then
        log "Docker is already installed."
        return 0
    fi

    # Update package lists
    log "Updating package lists..."
    sudo apt-get update -y

    # Set up Docker's GPG key
    log "Adding Docker's official GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository to apt sources
    log "Adding Docker repository to apt sources..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package lists again after adding the Docker repository
    log "Updating package lists after adding Docker repository..."
    sudo apt-get update -y

    # Install Docker packages
    log "Installing Docker packages..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Verify installation
    if command -v docker >/dev/null 2>&1; then
        log "Docker installation completed successfully."
    else
        log "Docker installation failed. Please check the logs and try again."
        return 1
    fi
}



# Main script execution.
install_pyenv
install_python
install_poetry
install_aws_cli
prepare_mount_point
generate_ssl_certificate
install_vscode_extensions
setup_ssh
install_docker

log "===== Python Software install completed successfully. ====="