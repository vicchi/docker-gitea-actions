# docker-gitea-actions

A base Docker image for Gitea actions, based on the offical Python Debian Bullseye image and with the following packages pre-installed:

* `ansible`
* `ansible-lint`
* `curl`
* `git`
* `make`
* `nodejs`
* `rsync`

# Usage

In a Gitea actions workflow:

```
    container:
      image:  ghcr.io/vicchi/gitea-actions:3.10-slim-bullseye
```
