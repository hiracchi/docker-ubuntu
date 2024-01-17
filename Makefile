PACKAGE=ubuntu
TAG=22.04
CONTAINER_NAME=ubuntu
ARG=
# PLATFORM = --platform linux/amd64


.PHONY: build start stop restart term logs

build:
	docker build ${PLATFORM} \
		-f Dockerfile \
		-t "${PACKAGE}:${TAG}" . 2>&1 | tee docker-build.log

build-amd64:
	docker build --platform linux/amd64 \
		--build-arg FIXUID_ARCH=amd64 \
		-f Dockerfile \
		-t "${PACKAGE}:${TAG}" . 2>&1 | tee docker-build.log

build-arm64:
	docker build --platform linux/arm64 \
		--build-arg FIXUID_ARCH=arm64 \
		-f Dockerfile \
		-t "${PACKAGE}:${TAG}" . 2>&1 | tee docker-build.log

debug:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker run ${PLATFORM} --init \
		-it --rm \
		--name ${CONTAINER_NAME} \
		--volume "${PWD}/work:/work" \
		--user ${USER_ID}:${GROUP_ID} \
		"${PACKAGE}:${TAG}" \
		/bin/bash


start:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	@echo "start docker as ${USER_ID}:${GROUP_ID}"
	docker run ${PLATFORM} --init \
		-d --rm \
		--name ${CONTAINER_NAME} \
		--user $(USER_ID):$(GROUP_ID) \
		--volume ${PWD}:/work \
		"${PACKAGE}:${TAG}" ${ARG}


start_as_root:
	@echo "start docker as root"
	docker run ${PLATFORM} --init \
		-d --rm \
		--name ${CONTAINER_NAME} \
		"${PACKAGE}:${TAG}" ${ARG}


stop:
	docker rm -f ${CONTAINER_NAME}


restart: stop start


term:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker exec -it --user $(USER_ID) ${CONTAINER_NAME} /bin/bash


logs:
	docker logs ${CONTAINER_NAME}
