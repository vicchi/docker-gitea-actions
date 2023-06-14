ARG IMAGE_VERSION=${IMAGE_VERSION}

FROM python:${IMAGE_VERSION}

ARG IMAGE_VERSION=${IMAGE_VERSION}

LABEL org.opencontainers.image.source=https://github.com/vicchi/docker-gitea-actions
LABEL org.opencontainers.image.url=https://github.com/vicchi/docker-gitea-actions/tree/master#readme
LABEL org.opencontainers.image.authors="Gary Gale <gary@vicchi.org>"
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL org.opencontainers.image.licenses=BSD-3-Clause
LABEL org.opencontainers.image.description="A base Docker image for Gitea actions, based on Python ${IMAGE_VERSION}"

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && \
    apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://get.docker.com | sh && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends git make ansible ansible-lint rsync nodejs yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
