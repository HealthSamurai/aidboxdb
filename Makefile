OWNER ?= healthsamurai
DB_REPO ?= ${OWNER}/aidboxdb
WALG_REPO ?= ${OWNER}/wal-g

PUSH_ON_BUILD ?= --push

WALG_VERSION ?= v3.0.5

PLATFORM ?= linux/amd64,linux/arm64

.PHONY: build clean

build: buildx-init
	docker buildx build \
		--build-arg PG_VERSION=${PG_VERSION} \
		--build-arg WALG_IMAGE=${WALG_REPO}:${WALG_VERSION} \
		--builder aidboxdb-builder \
		--platform ${PLATFORM} \
		-t ${DB_REPO}:${PG_VERSION} \
		${PUSH_ON_BUILD} .

build-all: build-walg
	@for v in $(shell cat postgres-versions); do \
	  PG_VERSION=$$v make build ; \
	done

build-walg: buildx-init
	docker buildx build \
		--build-arg WALG_VERSION=${WALG_VERSION} \
		--builder aidboxdb-builder \
		--platform ${PLATFORM} \
		-t ${WALG_REPO}:${WALG_VERSION} \
		-f Dockerfile.wal-g \
		${PUSH_ON_BUILD} .


## docker run

PG_VERSION ?= 18

POSTGRES_DB       ?= postgres
POSTGRES_PASSWORD ?= postgres
POSTGRES_USER     ?= postgres

run:
	docker run --rm -it \
		-e POSTGRES_DB=${POSTGRES_DB} \
		-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
		-e POSTGRES_USER=${POSTGRES_USER} \
		${DB_REPO}:${PG_VERSION}


## utility

buildx-init:
	@docker buildx create --name aidboxdb-builder --use || :

buildx-clean:
	@docker buildx rm aidboxdb-builder

clean: buildx-clean
