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

: "${DOCUMENT_NAME:=$1}"
: "${OUT_FILE:=$2}"
: "${VAULT:=$3}"

# check required variables
[[ -z ${DOCUMENT_NAME} ]] && echo "Document name is required!" && exit 1
[[ -z ${OUT_FILE} ]] && echo "Output file is required!" && exit 1
[[ -z ${VAULT} ]] && VAULT="Developer"

# list vaults
op vault list

# verify vault exist in list
VAULT_LIST="$(op vault list --format=json | jq -r '.[].name')"
if [[ ! ${VAULT_LIST} =~ ${VAULT} ]]; then
  echo "Vault ${VAULT} not found"
  exit 1
fi

# list documents
op document list --vault "${VAULT}"

# get sops privkey (force overwrite)
op document get "${DOCUMENT_NAME}" \
  --force \
  --out-file "${OUT_FILE}" \
  --vault "${VAULT}"
