#!/bin/bash

sudo chmod 666 /var/run/docker.sock

# Set variables
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Get ECR login password and log in to Docker
aws ecr get-login-password --region "$REGION" | \
docker login --username AWS --password-stdin "$ECR_URL"


sudo mkdir -p /data/jaimemain
s3fs jaimemain /data/jaimemain

sudo chown -R $USER /usr/local/



