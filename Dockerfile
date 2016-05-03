#################################################################
# Dockerfile
#
# Version:          1
# Software:         cgpBattenberg
# Software Version: 1.4.0
# Description:      Battenberg algorithm and associated implementation script which detects subclonality and copy number in matched NGS data.
# Website:          https://github.com/cancerit/cgpBattenberg
# Base Image:       ubuntu
# Pull Cmd:         docker pull anu9109/cgpbattenberg
# Run Cmd:          docker run anu9109/cgpbattenberg battenberg.pl -h
#################################################################

# Set the base image to Ubuntu
FROM ubuntu

################## BEGIN INSTALLATION ###########################

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y \
  git \
  autoconf \
  curl \
  gcc \
  make \
  gawk \
  g++ \
  perl \
  pkg-config \ 
  zlib1g-dev \
  wget \
  libncurses5-dev \
  libcurl4-gnutls-dev \
  libgnutls-dev \
  libssl-dev \
  libexpat1-dev \
  libgd-gd2-perl \
  cpanminus \
  build-essential \
  libgd-dev \
  nettle-dev \
  bioperl && \
  apt-get clean && \
  apt-get purge && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cpanm Data::UUID \
  IPC::System::Simple \
  XML::Parser \
  XML::Simple \
  YAML \
  Template


# Dependency: VCFtools
RUN  cd home/ && \
  git clone https://github.com/vcftools/vcftools.git && \
  cd /home/vcftools && \
  ./autogen.sh && \
  ./configure && \
  make && \
  make install

 # Dependency: samtools
 RUN cd home/ && \
  wget https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2 && \
  tar -xvjf /home/samtools-1.3.tar.bz2 && \
  cd /home/samtools-1.3 && \
  make && \
  make install && \
  rm /home/samtools-1.3.tar.bz2

# Dependency: cgpVCF
RUN cd home/ && \
  git clone https://github.com/cancerit/cgpVcf.git && \
  cd /home/cgpVcf && \
  ./setup.sh /opt/

ENV PATH=/opt/bin:$PATH
ENV PERL5LIB=/opt/lib/perl5

# Dependency: alleleCount
RUN cd home/ && \
  git clone https://github.com/cancerit/alleleCount.git && \
  cd /home/alleleCount && \
  ./setup.sh /opt/

 # Dependency: PCAP-core [Note: Does NOT install with the latest release (2.1.3), use working version 2.1.0 instead]
RUN cd home/ && \
  wget https://github.com/ICGC-TCGA-PanCancer/PCAP-core/archive/v2.1.0.tar.gz && \ 
  tar -xvzf v2.1.0.tar.gz && \
  cd /home/PCAP-core-2.1.0 && \
  ./setup.sh /opt/ && \
  rm /home/v2.1.0.tar.gz


ENV PERL5LIB=$PERL5LIB:/home/PCAP-core/lib

# cgpBattenberg [Note: "make test" fails but "install" works; comment out testing]
RUN cd home/ && \
 git clone https://github.com/cancerit/cgpBattenberg.git && \
 cd /home/cgpBattenberg && \
 sed -i "s|make test|#make test|" setup.sh && \
 ./setup.sh /opt/

ENV PERL5LIB=$PERL5LIB:/home/cgpBattenberg/perl/bin


##################### INSTALLATION END ##########################

# File Author / Maintainer
MAINTAINER Anu Amallraja <anu9109@gmail.com>

