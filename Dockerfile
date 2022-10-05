# For CENTOS 6

FROM centos:6 as centos-6-without-eol-issues
RUN curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo; \
    curl https://www.getpagespeed.com/files/centos6-epel-eol.repo --output /etc/yum.repos.d/epel.repo
RUN yum -y update

FROM centos-6-without-eol-issues as centos-6-build-base
RUN yum groupinstall -y "Development Tools"; \
    yum install -y curl wget boost python-devel


FROM centos-6-build-base as centos-6-deps-addn

# Add additional dependencies
### This script happens at build time
### And hence must always be present
COPY deps-install.sh .
RUN chmod +x deps-install.sh; \
    ./deps-install.sh; \
    rm -rf deps-install.sh;

FROM centos-6-deps-addn as centos-6-builder

# FOR UBUNTU
FROM ubuntu as ubuntu-build-base
RUN apt update -y; \
    apt upgrade -y; \
    apt install -y build-essential libboost-all-dev python3; \
    apt clean -y

FROM ubuntu-build-base as ubuntu-deps-addn

# Add additional dependencies
### This script happens at build time
### And hence must always be present
COPY deps-install.sh .
RUN chmod +x deps-install.sh; \
    ./deps-install.sh; \
    rm -rf deps-install.sh;

FROM ubuntu-build-base as ubuntu-builder
