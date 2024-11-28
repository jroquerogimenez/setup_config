#!/bin/bash

sudo apt-get update 

sudo apt-get install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    bison \
    byacc \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    default-jdk \
    default-jre \
    ed \
    gfortran \
    git \
    gnupg1 \
    gnupg2 \
    graphviz \
    gzip \
    less \
    libbz2-dev \
    libboost-all-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    liblzma-dev \
    libncurses5-dev \
    libpcre2-dev \
    libreadline8 \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxmlsec1-dev \
    libxml2-dev \
    libz-dev \
    littler \
    llvm \
    locales \
    make \
    nano \
    procps \
    python3-dev \
    rsync \
    s3fs \
    ssh \
    tk-dev \
    unzip \
    vim \
    wget \
    xz-utils \
    zlib1g-dev 

sudo apt-get clean -y 
sudo rm -rf /var/lib/apt/lists/*


