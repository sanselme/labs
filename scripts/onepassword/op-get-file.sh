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

: "${FILE_NAME:=$1}"
: "${FILE:=$2}"
: "${VAULT:=$3}"

# check required variables
[[ -z ${FILE_NAME} ]] && echo "File name is required!" && exit 1
[[ -z ${FILE} ]] && echo "File is required!" && exit 1

# check optional variables
[[ -z ${VAULT} ]] && VAULT="Developer"

# verify vault exist in list
VAULT_LIST="$(op vault list --format=json | jq -r '.[].name')"
if [[ ! ${VAULT_LIST} =~ ${VAULT} ]]; then
  echo "Vault ${VAULT} not found"
  exit 1
fi

# get file
op document get "${FILE_NAME}" \
  --force \
  --out-file "${FILE}" \
  --vault "${VAULT}"
