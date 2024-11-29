#!/bin/bash

sudo chmod 666 /var/run/docker.sock

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account>.dkr.ecr.us-east-1.amazonaws.com

sudo mkdir -p /data/jaimemain
s3fs jaimemain /data/jaimemain

sudo chown -R $USER /usr/local/



