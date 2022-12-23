#!/usr/bin/env make

.DEFAULT_GOAL  := help
.DEFAULT_SHELL := /bin/bash

GO     := $(GOBIN)/go
GOARCH := $(shell go env GOARCH)
GOOS   := $(shell go env GOOS)
GOLINT ?= $(shell command -v golangci-lint 2>/dev/null)

EXECUTABLE        ?= dist/tekton-learning-go-$(GOOS)_$(GOARCH)
PROJECT_MAIN      := $(shell find . -type f -name main.go)
PROJECT_CHANGESET := $(shell git rev-parse --verify HEAD 2>/dev/null)

DOCKER_REGISTRY           := ghcr.io
DOCKER_REGISTRY_NAMESPACE := jjuarez
DOCKER_SERVICE_NAME       := tekton-learning-go

PROJECT_MAIN  := $(shell find . -type f -name main.go)
EXECUTABLE    ?= dist/service-$(GOOS)_$(GOARCH)

DOCKER_IMAGE := $(DOCKER_REGISTRY)/$(DOCKER_REGISTRY_NAMESPACE)/$(DOCKER_SERVICE_NAME)
DOCKER_FILE  ?= Dockerfile

PROJECT_CHANGESET := $(shell git rev-parse --verify HEAD 2>/dev/null)

define assert-set
	@$(if $($1),,$(error $(1) environment variable is not defined))
endef

.PHONY: help
help: ## Shows this pretty help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z//_-]+:.*?##/ { printf " %-20s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

#
# Golang rules
#
.PHONY: lint
lint: ## Lint the source code
	$(call assert-set,GOLINT)
	$(call assert-command,$(GOLINT))
	@$(GOLINT) run ./...

$(EXECUTABLE): $(PROJECT_MAIN)
ifdef PROJECT_VERSION
	@$(GO) build -v -ldflags "-X 'main.Version=$(PROJECT_VERSION)'" -o $(EXECUTABLE) $<
else
	@$(GO) build -v -ldflags "-X 'main.Version=$(PROJECT_CHANGESET)'" -o $(EXECUTABLE) $<
endif

.PHONY: build
build: $(EXECUTABLE) ## Build the project

.PHONY: test
test: ## Unit tests
	@$(GO) test -v ./...

.PHONY: clean
clean: ## Clean the project executable
	@$(GO) clean -v ./...
	@rm -f $(EXECUTABLE)

#
# Docker rules
#
.PHONY: docker/login
docker/login:
	$(call assert-set,GITHUB_USERNAME)
	$(call assert-set,GITHUB_TOKEN)
	@echo $(GITHUB_TOKEN)|docker login --username $(GITHUB_USERNAME) --password-stdin $(DOCKER_REGISTRY)

.PHONY: docker/build
docker/build: docker/login ## Makes the Docker build and takes care of the remote cache by target
ifdef PROJECT_CHANGESET
	@docker image build \
    --tag $(DOCKER_IMAGE):$(PROJECT_CHANGESET) \
    --tag $(DOCKER_IMAGE):latest \
    --file $(DOCKER_FILE) \
    .
else
	@docker image build \
    --tag $(DOCKER_IMAGE):latest \
    --file $(DOCKER_FILE) \
    .
endif
	@docker image push $(DOCKER_IMAGE):latest

.PHONY: docker/release
docker/release: docker/build ## Builds and release over the Docker registry the image
	@docker image push $(DOCKER_IMAGE):$(PROJECT_CHANGESET)
ifdef PROJECT_VERSION
	@docker image tag  $(DOCKER_IMAGE):$(PROJECT_CHANGESET) $(DOCKER_IMAGE):$(PROJECT_VERSION)
	@docker image push $(DOCKER_IMAGE):$(PROJECT_VERSION)
else
	$(warning The release rule should have a PROJECT_VERSION defined)
endif
