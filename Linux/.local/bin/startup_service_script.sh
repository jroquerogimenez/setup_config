#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail


# Variables
LOG_FILE="/var/log/startup_service.log"

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Redirect all output and errors to the log file
exec > >(sudo tee -a "$LOG_FILE") 2>&1

# Start of the script
log "===== Starting startup service script ====="

sudo chmod 666 /var/run/docker.sock

# Set variables
ACCOUNT_ID=$("$HOME/.local/bin/aws" sts get-caller-identity --query Account --output text)

# Get the list of all AWS regions
regions=$("$HOME/.local/bin/aws" ec2 describe-regions --query "Regions[*].RegionName" --output text)

# Initialize an empty list to store regions with ECR repositories
ecr_regions=()

# Check each region for ECR repositories
for region in $regions; do
  echo "Checking region: $region"
  
  # Attempt to describe ECR repositories in the region
  ecr_repositories=$("$HOME/.local/bin/aws" ecr describe-repositories --region "$region" --registry-id "$ACCOUNT_ID" --output text)

  if [ -n "$ecr_repositories" ]; then
    echo "Found ECR repositories in region: $region"
    ecr_regions+=("$region")
  fi
done

# Check if the list contains exactly one region
if [ ${#ecr_regions[@]} -eq 1 ]; then
  echo "Only one region has ECR repositories: ${ecr_regions[0]}"
  
  REGION=${ecr_regions[0]}
  ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

  # Get ECR login password and log in to Docker
  "$HOME/.local/bin/aws" ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$ECR_URL"

else
  echo "Found multiple or no regions with ECR repositories: ${#ecr_regions[@]}"
fi


log "===== Startup service script completed successfully. ====="



