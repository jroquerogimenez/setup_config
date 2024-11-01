FROM ubuntu:22.04

LABEL authors="Jaime Roquero Gimenez" \
    description="Base docker image for RGTechnologies."


ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive


ARG BUILD_VER=0.0
ARG GIT_BRANCH="master"
ENV GIT_BRANCH="${GIT_BRANCH}"
ENV BUILD_VER="${BUILD_VER}"


# Set one or more  labels
LABEL version="${BUILD_VER}"

# Install basic OS tools on top of ubuntu to facilitate next steps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
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
    libreadline8 \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtbb
    libz-dev \
    littler \
    llvm \
    locales \
    make \
    nano \
    procps \
    python3-dev \
    #software-properties-common \
    s3fs \
    ssh \
    tk-dev \
    unzip \
    vim \
    wget \
    xz-utils \
    zlib1g-dev \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*


RUN apt-get update \
    ncbi-blast+ \
    bwa \
    bowtie2 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*


## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV HOME /home/ubuntu

## Install Nextflow

WORKDIR /usr/local/bin/
RUN wget -qO- https://get.nextflow.io | bash
RUN chmod 755 nextflow

## Install samtools

WORKDIR /usr/local/lib
RUN wget https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2
RUN tar -xvf samtools-1.17.tar.bz2 && rm samtools-1.17.tar.bz2
WORKDIR /usr/local/lib/samtools-1.17
RUN ./configure --prefix=/usr/local/
RUN make
RUN make install

# Install bioawk

WORKDIR /usr/local/lib
RUN git clone https://github.com/lh3/bioawk.git
WORKDIR /usr/local/lib/bioawk
RUN make
RUN ln -s /usr/local/lib/bioawk/bioawk /usr/local/bin

# Install Bedtools

WORKDIR /usr/local/bin
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary
RUN chmod 755 /usr/local/bin/bedtools

# Install AWS CLI

WORKDIR /usr/local/lib
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip && rm awscliv2.zip
RUN ./aws/install

# Install pyenv

RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"
RUN pyenv init -
RUN pyenv install 3.10.12
RUN pyenv global 3.10.12

# Install personal setup
WORKDIR $HOME
RUN git clone https://github.com/jroquerogimenez/setup_config.git
RUN cp -rT $HOME/setup_config/Linux $HOME/

# Install Poetry

RUN curl -sSL https://install.python-poetry.org | /home/ubuntu/.pyenv/shims/python - --yes
ENV PATH="$HOME/.local/bin:$PATH"
RUN poetry config virtualenvs.in-project true
WORKDIR $HOME/workspace
RUN mkdir workspace && mv $HOME/pyproject.toml $HOME/workspace/
RUN poetry env use $HOME/.pyenv/shims/python
RUN poetry install

# # Install Picard tools

# WORKDIR /usr/local/lib
# RUN git clone https://github.com/broadinstitute/picard.git
# WORKDIR /usr/local/lib/picard
# RUN ./gradlew shadowJar
# RUN ln -s /usr/local/lib/picard/build/libs/picard.jar /usr/local/bin
# RUN chmod 755 /usr/local/bin/picard.jar
# RUN sh -c 'echo "#!/bin/bash\n java -jar /usr/local/bin/picard.jar \$@"> picard_executable'
# RUN mv picard_executable /usr/local/bin/picard
# RUN chmod 755 /usr/local/bin/picard

# Install nomad

WORKDIR $HOME
RUN git clone https://github.com/refresh-bio/nomad
WORKDIR $HOME/nomad
RUN make -j
RUN make install

# Install splash
WORKDIR /usr/local/bin
RUN curl -L https://github.com/refresh-bio/SPLASH/releases/download/v2.1.4/splash-2.1.4.linux.x64.tar.gz | tar xz

# Install UCSC toolkit

WORKDIR /usr/local/bin
RUN rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ ./

# Install STAR

# Actually there are already compiled binary files.
WORKDIR /usr/local/lib
RUN wget https://github.com/alexdobin/STAR/archive/2.7.11a.tar.gz
RUN tar -xzf 2.7.11a.tar.gz
WORKDIR /usr/local/lib/STAR-2.7.11a/source
RUN make STAR

# Install NCBI datasets CLI tool.
WORKDIR /usr/local/lib
RUN curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets'
RUN curl -o dataformat 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat'
RUN chmod +x datasets dataformat

# Install cufflinks
WORKDIR	/usr/local/lib
RUN wget http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz
RUN tar -xvf cufflinks-2.2.1.Linux_x86_64.tar.gz
# then manually symlink all the executables to /usr/local/bin. Not the most elegant way.
# ln -s /usr/local/lib/cufflinks-2.2.1.Linux_x86_64/gtf_to_sam /usr/local/bin/gtf_to_sam


# Install Aspera: IBM software for fast file download that is used by SRA.
# Follow instructions in IBM software, download a shell script and execute it. It will install binaries
# in ~/.aspera/connect/bin/
# Then make those binaries accessible by creating symlinks in /usr/local/bin. Navigate to the above folder then
# find . -type f -executable -exec sh -c 'file="{}"; sudo ln -s "$(pwd)/${file#./}" /usr/local/bin/' \;
# To update a package and its symlinks, especially if some symlinks in /usr/local/bin are symlinks of symlinks in /usr/local/lib/...
# find . \( -type f -executable -o -type l \) -exec sh -c 'for file; do sudo ln -sf "$(realpath -- "$file")" "/usr/local/bin/$(basename "$file")"; done' sh {} +

# Install liftOver
# https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver

# Install Salmon
WORKDIR /usr/local/lib
RUN wget https://github.com/COMBINE-lab/salmon/archive/refs/tags/v1.10.1.tar.gz
RUN tar xzvf v1.10.1.tar.gz



# Clean up

WORKDIR $HOME

RUN cd /home \
    mkdir matplotlib_tmp
ENV MPLCONFIGDIR="/home/matplotlib_tmp/"
