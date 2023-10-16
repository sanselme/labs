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
source scripts/load-env.sh

GIT_BRANCH="${GIT_BRANCH:-$1}"
# SITE_NAME="${SITE_NAME:-$2}" # FIXME: site name

GITHUB_REPO="${GITHUB_REPO:-$3}"
GITHUB_TOKEN="${GITHUB_TOKEN:-$4}"
GITHUB_USER="${GITHUB_USER:-$5}"

# check parameters
[[ -z ${GITHUB_REPO} ]] && echo "GITHUB_REPO is not set" && exit 1
[[ -z ${GITHUB_TOKEN} ]] && echo "GITHUB_TOKEN is not set" && exit 1
[[ -z ${GITHUB_USER} ]] && echo "GITHUB_USER is not set" && exit 1
[[ -z ${SITE_NAME} ]] && echo "SITE_NAME is not set" && exit 1

# check prerequisites
flux check --pre

echo """
Branch: ${GIT_BRANCH}
Repo:   ${GITHUB_REPO}
Site:   ${SITE_NAME}
User:   ${GITHUB_USER}
"""

# bootstrap flux
flux bootstrap github \
  --branch "${GIT_BRANCH}" \
  --namespace cicd \
  --owner "${GITHUB_USER}" \
  --path "build/site/maas" \
  --personal \
  --repository "${GITHUB_REPO}" \
  --token-auth
