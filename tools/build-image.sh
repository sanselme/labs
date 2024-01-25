#!/bin/bash

# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
set -e

IMAGES=(
  clos
  inception
)

# : "${BASE_IMAGE:=mcr.microsoft.com/devcontainers/base:dev-ubuntu}"
: "${BASE_IMAGE:=ubuntu:20.04}"
: "${DOCKERFILE_ROOT:=build/pkg/img}"
: "${PLATFORM:=linux/amd64,linux/arm64}"
: "${REPO:=ghcr.io/sanselme/labs}"
: "${TAG:=v0.1.0}"

# build and push image
for image in "${IMAGES[@]}"; do
  DOCKERFILE="${DOCKERFILE_ROOT}/${image}/Dockerfile"
  IMG="${REPO}/${image}"

  docker buildx build \
    --file "${DOCKERFILE}" \
    --label "org.opencontainers.image.authors=Schubert Anselme <schubert@anselm.es>" \
    --label "org.opencontainers.image.created=$(date)" \
    --label "org.opencontainers.image.description=${image}" \
    --label "org.opencontainers.image.documentation=https://github.com/sanselme/labs/blob/main/README.md" \
    --label "org.opencontainers.image.licenses=GPL-3.0-or-later" \
    --label "org.opencontainers.image.source=https://github.com/sanselme/labs" \
    --label "org.opencontainers.image.title=${image}" \
    --label "org.opencontainers.image.url=https://github.com/users/sanselme/packages/container/package/labs%2F${image}" \
    --label "org.opencontainers.image.version=${TAG}" \
    --platform "${PLATFORM}" \
    --build-arg BASE_IMAGE="${BASE_IMAGE}" \
    --push \
    --tag "${IMG}":"${TAG}" \
    --tag "${IMG}":latest \
    .

  # sign image
  ./tools/cosign/sign.sh "${IMG}":"${TAG}"
done
