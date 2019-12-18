FROM ubuntu:18.04

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git \
    gcc \
    python3-dev \
    python3-pip \
    python3-virtualenv \
    doxygen \
    ditaa \
    libxml2-dev \
    libxslt1-dev \
    graphviz \
    ant \
    zlib1g-dev \
    cython3 \
    python \
    python-pip
RUN pip install virtualenv
RUN mkdir /ceph-korean-doc
WORKDIR /ceph-korean-doc