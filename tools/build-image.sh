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

: "${DOCKERFILE:=build/pkg/img/Dockerfile}"
: "${IMG:=ghcr.io/sanselme/labs/inception}"
: "${PLATFORM:=linux/amd64,linux/arm64}"
: "${TAG:=v0.1.0}"

# build and push image
docker buildx build \
  --file "${DOCKERFILE}" \
  --label "org.opencontainers.image.authors=Schubert Anselme <schubert@anselm.es>" \
  --label "org.opencontainers.image.created=$(date)" \
  --label "org.opencontainers.image.description=" \
  --label "org.opencontainers.image.documentation=https://github.com/sanselme/labs/blob/main/README.md" \
  --label "org.opencontainers.image.licenses=GPL-3.0-or-later" \
  --label "org.opencontainers.image.source=https://github.com/sanselme/labs" \
  --label "org.opencontainers.image.title=Inception" \
  --label "org.opencontainers.image.url=https://github.com/users/sanselme/packages/container/package/labs%2Finception" \
  --label "org.opencontainers.image.version=${TAG}" \
  --platform "${PLATFORM}" \
  --push \
  --tag "${IMG}":"${TAG}" \
  --tag "${IMG}":latest \
  .

# TODO: sign image
# ./scripts/cosign/sign.sh "${IMG}":"${TAG}"
