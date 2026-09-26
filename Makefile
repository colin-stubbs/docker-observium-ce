IMAGE      ?= docker.io/colinstubbs/observium-ce
TAG        ?= latest
BUILDER    ?= observium-ce
CONTEXT    ?= ./build
DOCKERFILE ?= $(CONTEXT)/Dockerfile

export IMAGE TAG

.PHONY: help builder build load push lint scan check

help:
	@echo "make build  - linux/amd64 + linux/arm64 (buildx cache)"
	@echo "make load   - native platform only, into the local docker engine"
	@echo "make push   - linux/amd64 + linux/arm64 to the registry (docker login first)"
	@echo "make lint   - hadolint + shellcheck"
	@echo "make scan   - trivy HIGH/CRITICAL on $(IMAGE):$(TAG) (needs a loaded image)"
	@echo "make check  - lint"

builder:
	docker buildx inspect $(BUILDER) >/dev/null 2>&1 || \
	  docker buildx create --name $(BUILDER) --driver docker-container --bootstrap
	docker buildx use $(BUILDER)
	docker buildx inspect --bootstrap >/dev/null

# Multi-arch cannot --load into the engine. Result stays in the buildx builder.
build: builder
	docker buildx bake --builder $(BUILDER)

# Local compose/run: one architecture only.
load: builder
	docker buildx bake --builder $(BUILDER) \
	  --set observium.platform=linux/$$(docker version -f '{{.Server.Arch}}') \
	  --load

push: builder
	docker buildx bake --builder $(BUILDER) --push

lint:
	docker run --rm -v "$(CURDIR):/src:ro" -w /src hadolint/hadolint \
	  hadolint --config .hadolint.yaml $(DOCKERFILE)
	docker run --rm -v "$(CURDIR):/src:ro" -w /src koalaman/shellcheck \
	  build/observium-init.sh build/apache-init.sh

scan:
	trivy image --config trivy.yaml --severity HIGH,CRITICAL --ignore-unfixed \
	  $(IMAGE):$(TAG)

check: lint
