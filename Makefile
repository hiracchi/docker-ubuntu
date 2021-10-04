PACKAGE=ghcr.io/hiracchi/ubuntu
TAG=latest
CONTAINER_NAME=ubuntu
ARG=


.PHONY: build start stop restart term logs

build:
	docker build \
		-f Dockerfile \
		-t "${PACKAGE}:${TAG}" . 2>&1 | tee docker-build.log


start:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	@echo "start docker as ${USER_ID}:${GROUP_ID}"
	docker run -d \
		--rm \
		--name ${CONTAINER_NAME} \
		-u $(USER_ID):$(GROUP_ID) \
		--volume ${PWD}:/work \
		"${PACKAGE}:${TAG}" ${ARG}


start_as_root:
	@echo "start docker as root"
	docker run -d \
		--rm \
		--name ${CONTAINER_NAME} \
		"${PACKAGE}:${TAG}" ${ARG}

start_bash:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	@echo "start docker as ${USER_ID}:${GROUP_ID}"
	docker run -it \
		--rm \
		--name ${CONTAINER_NAME} \
		-u $(USER_ID):$(GROUP_ID) \
		--volume ${PWD}:/work \
		"${PACKAGE}:${TAG}" /bin/bash

stop:
	docker rm -f ${CONTAINER_NAME}


restart: stop start


term:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker exec -it --user $(USER_ID) ${CONTAINER_NAME} /bin/bash


logs:
	docker logs ${CONTAINER_NAME}
