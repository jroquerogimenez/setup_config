#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Logging function to print messages with timestamp.
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") [LOG] $1"
}

# Function to print error messages.
error() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") [ERROR] $1" >&2
}

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
        source ~/.bashrc
        log "pyenv installed and shell configuration updated."
    fi
}

# Function to install a specific Python version using pyenv.
install_python() {
    PYTHON_VERSION=3.12.7
    log "Installing Python $PYTHON_VERSION using pyenv..."
    if pyenv versions | grep -q $PYTHON_VERSION; then
        log "Python $PYTHON_VERSION is already installed."
    else
        pyenv install $PYTHON_VERSION
        log "Python $PYTHON_VERSION installed."
    fi
    pyenv global $PYTHON_VERSION
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
    poetry config virtualenvs.in-project true
    log "Poetry configured to create virtual environments in the project directory."
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
    cat "$SSH_KEY.pub"
    read -p "Press enter after uploading the SSH key to GitHub..."
    log "Attempting to connect to GitHub via SSH..."
    ssh -T git@github.com || true
}

# Function to install AWS CLI.
install_aws_cli() {
    log "Installing AWS CLI..."
    if command -v aws >/dev/null 2>&1; then
        log "AWS CLI is already installed."
    else
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        ./aws/install --install-dir $HOME/.local/lib/ --bin-dir $HOME/.local/bin/
        rm -rf aws awscliv2.zip

        # # Update PATH for the current session and future sessions.
        # echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        # export PATH="$HOME/.local/bin:$PATH"
        log "AWS CLI installed."
    fi
}

# Function to configure AWS CLI.
configure_aws_cli() {
    log "Configuring AWS CLI..."
    aws configure
    log "AWS credentials stored in $HOME/.aws/credentials."
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



mv $HOME/setup_config/Linux/* $HOME/

sudo bash $HOME/.local/bin/home_mount_startup.sh
sudo bash $HOME/.local/bin/setup_services_startup.sh
sudo bash $HOME/.local/bin/linux_software_startup.sh


# Main script execution.
install_pyenv
install_python
install_poetry
configure_git
setup_ssh
install_aws_cli
# configure_aws_cli
prepare_mount_point
generate_ssl_certificate
install_vscode_extensions

log "Setup completed successfully."
