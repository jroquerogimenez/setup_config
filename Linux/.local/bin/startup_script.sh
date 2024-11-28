#!/bin/bash

sudo chmod 666 /var/run/docker.sock

sudo chown -R $USER /usr/local/

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 677993236947.dkr.ecr.us-east-1.amazonaws.com

mkdir -p /home/ubuntu/mnt/jaimemain

s3fs jaimemain /home/ubuntu/mnt/jaimemain
