#!/bin/sh

set -e

export DOCKER_REGISTRY_REPO="${DOCKER_REGISTRY_REPO:-"$(basename "$PWD")"}"

export VERSION=$(cat version.txt)
export TOOLCHAIN=$(cat toolchain.txt)
echo "Image version ${VERSION}, building with toolchain ${TOOLCHAIN}."

echo "Building image..."
docker build --build-arg "VERSION=${VERSION}" --build-arg "TOOLCHAIN=${TOOLCHAIN}" -t "${DOCKER_REGISTRY_REPO}:${VERSION}" .
echo "Image ready."

if [ -n "${DOCKER_REGISTRY}" ] && [ -n "${DOCKER_REGISTRY_USER}" ] && [ -n "${DOCKER_REGISTRY_PASSWORD}" ]
then
	echo "Logging into ${DOCKER_REGISTRY}..."
	docker login -u="${DOCKER_REGISTRY_USER}" -p="${DOCKER_REGISTRY_PASSWORD}" "${DOCKER_REGISTRY}"
	echo "Pushing image to ${DOCKER_REGISTRY_REPO}:${VERSION}..."
	docker push "${DOCKER_REGISTRY_REPO}:${VERSION}"
fi
