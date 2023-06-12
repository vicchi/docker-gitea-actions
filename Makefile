SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -O extglob -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(.DEFAULT_GOAL),)
ifneq ($(shell test -f .env; echo $$?), 0)
$(error Cannot find a .env file; copy .env.sample and customise)
endif
endif

# Wrap the build in a check for an existing .env file
ifeq ($(shell test -f .env; echo $$?), 0)
include .env
ENVVARS := $(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' .env )
$(foreach var,$(ENVVARS),$(eval $(shell echo export $(var)="$($(var))")))

.DEFAULT_GOAL := help

UBUNTU_VERSION := ${UBUNTU_VERSION}
IMAGE_VERSION := ${IMAGE_VERSION}
VERSION := ${IMAGE_VERSION}
COMMIT_HASH := $(shell git log -1 --pretty=format:"sha-%h")
PLATFORMS := "linux/arm/v7,linux/arm64/v8,linux/amd64"

BUILD_FLAGS ?= 

ACTIONS := gitea-actions
ACTIONS_BUILDER := $(ACTIONS)-builder
ACTIONS_USER := vicchi
ACTIONS_REPO := ${GITHUB_REGISTRY}/${ACTIONS_USER}
ACTIONS_IMAGE := ${ACTIONS}
ACTIONS_DOCKERFILE := ./docker/${ACTIONS}/Dockerfile

HADOLINT_IMAGE := hadolint/hadolint

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' Makefile

.PHONY: lint
lint: lint-dockerfiles	## Run all linters on the code base

.PHONY: lint-dockerfiles
.PHONY: _lint-dockerfiles ## Lint all Dockerfiles
lint-dockerfiles: lint-${ACTIONS}-dockerfile

.PHONY: lint-${ACTIONS}-dockerfile
lint-${ACTIONS}-dockerfile:
	$(MAKE) _lint_dockerfile -e BUILD_DOCKERFILE="${ACTIONS_DOCKERFILE}"

BUILD_TARGETS := build_gitea_actions

.PHONY: build
build: $(BUILD_TARGETS) ## Build all images

REBUILD_TARGETS := rebuild_gitea_actions

.PHONY: rebuild
rebuild: $(REBUILD_TARGETS) ## Rebuild all images (no cache)

# gitea_actions targets

build_gitea_actions:	repo_login	## Build the gitea_actions image
	$(MAKE) _build_image \
		-e BUILD_DOCKERFILE=./docker/$(ACTIONS)/Dockerfile \
		-e BUILD_IMAGE=$(ACTIONS_IMAGE)

rebuild_gitea_actions:	## Rebuild the gitea_actions image (no cache)
	$(MAKE) _build_image \
		-e BUILD_DOCKERFILE=./docker/$(ACTIONS)/Dockerfile \
		-e BUILD_IMAGE=$(ACTIONS_IMAGE) \
		-e BUILD_FLAGS="--no-cache"

.PHONY: _lint_dockerfile
_lint_dockerfile:
	docker run --rm -i -e HADOLINT_IGNORE=DL3008,DL3018,DL3003 ${HADOLINT_IMAGE} < ${BUILD_DOCKERFILE}

.PHONY: _build_image
_build_image:
	docker buildx inspect $(ACTIONS_BUILDER) > /dev/null 2>&1 || \
		docker buildx create --name $(ACTIONS_BUILDER) --bootstrap --use
	docker buildx build --platform=$(PLATFORMS) \
		--file ${BUILD_DOCKERFILE} --push \
		--tag ${ACTIONS_REPO}/${BUILD_IMAGE}:latest \
		--tag ${ACTIONS_REPO}/${BUILD_IMAGE}:$(VERSION) \
		--tag ${ACTIONS_REPO}/${BUILD_IMAGE}:$(COMMIT_HASH) \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg IMAGE_VERSION=${IMAGE_VERSION} \
		$(BUILD_FLAGS) \
		--ssh default $(BUILD_FLAGS) .

.PHONY: repo_login
repo_login:
	echo "${GITHUB_PAT}" | docker login ${GITHUB_REGISTRY} -u ${GITHUB_USER} --password-stdin

# No .env file; fail the build
else
.DEFAULT:
	$(error Cannot find a .env file; copy .env.sample and customise)
endif
