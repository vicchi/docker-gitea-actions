ARG UBUNTU_VERSION
ARG IMAGE_VERSION

FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.source=https://github.com/vicchi/docker-gitea-actions
LABEL org.opencontainers.image.url=https://github.com/vicchi/docker-gitea-actions/tree/master#readme
LABEL org.opencontainers.image.authors="Gary Gale <gary@vicchi.org>"
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL org.opencontainers.image.licenses=BSD-3-Clause
LABEL org.opencontainers.image.description="A base Docker image for Gitea actions, based on Ubuntu and with Python3 and Node pre-installed"

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
