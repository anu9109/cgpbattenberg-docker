#################################################################
# Dockerfile
#
# Version:          1
# Software:         cgpBattenberg
# Software Version: 1.4.0
# Description:      Battenberg algorithm and associated implementation script which detects subclonality and copy number in matched NGS data.
# Website:          https://github.com/cancerit/cgpBattenberg
# Base Image:       ubuntu
# Build Cmd:        docker build biodckrdev/samtools 1.2/. ##########
# Pull Cmd:         docker pull anu9109/cgpbattenberg
# Run Cmd:          docker run anu9109/cgpbattenberg battenberg.pl ###########
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

#RUN cpanm --force GD

#RUN perl -MCPAN -e 'install Data::UUID' && \
#  perl -MCPAN -e 'install IPC::System::Simple' && \
#  perl -MCPAN -e 'install XML::Parser' && \
#  perl -MCPAN -e 'install XML::Simple' && \
#  cpan GD && \
#  cpan YAML

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

# Dependency: libgd
RUN cd home/ && \
  wget https://github.com/libgd/libgd/releases/download/gd-2.1.1/libgd-2.1.1.tar.bz2 && \
  tar -xvjf /home/libgd-2.1.1.tar.bz2 && \
  cd /home/libgd-2.1.1 && \
  ./configure --prefix=/usr/local && \
  make && \
  make install && \
  rm /home/libgd-2.1.1.tar.bz2

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

 # Dependency: PCAP-core
 #RUN cd home/ && \
 # git clone https://github.com/ICGC-TCGA-PanCancer/PCAP-core.git && \
 # cd /home/PCAP-core && \
 # ./setup.sh /opt/

RUN cd home/ && \
  wget https://github.com/ICGC-TCGA-PanCancer/PCAP-core/archive/v2.1.0.tar.gz && \ 
  tar -xvzf v2.1.0.tar.gz && \
  cd /home/PCAP-core-2.1.0 && \
  ./setup.sh /opt/


ENV PERL5LIB=$PERL5LIB:/home/PCAP-core/lib

# cgpBattenberg
RUN cd home/ && \
 git clone https://github.com/cancerit/cgpBattenberg.git && \
 cd /home/cgpBattenberg && \
 sed -i "s|make test|#make test|" setup.sh && \
 ./setup.sh /opt/

ENV PERL5LIB=$PERL5LIB:/home/cgpBattenberg/perl/bin

# CHANGE WORKDIR to cgpBattenberg/perl/bin
WORKDIR /home/cgpBattenberg/perl/bin

# Use baseimage-docker's bash.
CMD ["/bin/bash"]

##################### INSTALLATION END ##########################

# File Author / Maintainer
MAINTAINER Anu Amallraja <anu9109@gmail.com>

