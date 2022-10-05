FROM centos:6 as centos-6-without-eol-issues
RUN curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo; \
    curl https://www.getpagespeed.com/files/centos6-epel-eol.repo --output /etc/yum.repos.d/epel.repo
RUN yum -y update

FROM centos-6-without-eol-issues as centos-6-build-base
RUN yum groupinstall -y "Development Tools"; \
    yum install -y curl wget boost python-devel

