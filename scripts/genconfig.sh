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
source scripts/load-env.sh

: "${SITE:=$1}"
[[ -z ${SITE} ]] && echo "Usage: $0 <site>" && exit 1

: "${BUILD_ROOT:=build/site/${SITE}}"
: "${CLOUDINIT:=${BUILD_ROOT}/cloud-init.yaml}"
: "${KEYSTORE_NAME:=key-store-${SITE}}"
: "${KEYSTORE:=${BUILD_ROOT}/${SITE}.pfx}"
: "${OP_CREDS_TITLE:=credentials-${SITE}}"
: "${OP_SSH_KEY:=id_rsa_cloudos}"
: "${SETUP_MACHINE_SCRIPT=$(cat scripts/setup-machine.sh)}"
: "${SSH_PUB_KEY:=${BUILD_ROOT}/id_rsa.pub}"

# retrieve ssh key
if [[ -f ${SSH_PUB_KEY} ]]; then
  echo "SSH key already generated!!!"
else
  SSH_PUB_KEY_CONTENT=$(./scripts/onepassword/op-get-item.sh "${OP_SSH_KEY}" | jq '.fields[] | select(.id | contains("public_key")) | .value')
  touch "${SSH_PUB_KEY}"
  echo "${SSH_PUB_KEY_CONTENT}" | tr -d '"' >"${SSH_PUB_KEY}"
fi

SSH_PUB_KEY=$(cat "${SSH_PUB_KEY}")
export SSH_PUB_KEY

# retrieve keystore
if [[ -f ${KEYSTORE} ]]; then
  echo "Keystore already generated!!!"
else
  ./scripts/onepassword/op-get-file.sh "${KEYSTORE_NAME}" "${KEYSTORE}"
fi

# TODO: retrieve ca cert
# KEYSTORE_SECRET="$(./scripts/onepassword/op-get-item.sh "${OP_CREDS_TITLE}" keystore | jq '.value')"
# openssl pkcs12 \
#   -in "${KEYSTORE}" \
#   -nodes \
#   -nokeys \
#   -passin pass:"${KEYSTORE_SECRET}" |
#   sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'

BOOTSTRAP_KUBECONFIG=""
BYOH_HOSTAGENT_SERVICE="$(cat deployment/baremetal/byoh-hostagent.service)"
BYOH_HOSTAGENT_WATCHER_PATH="$(cat deployment/baremetal/byoh-hostagent-watcher.path)"
BYOH_HOSTAGENT_WATCHER_SERVICE="$(cat deployment/baremetal/byoh-hostagent-watcher.service)"
SETUP_MACHINE_SCRIPT="$(cat scripts/setup-machine.sh)"
export \
  BOOTSTRAP_KUBECONFIG \
  BYOH_HOSTAGENT_SERVICE \
  BYOH_HOSTAGENT_WATCHER_PATH \
  BYOH_HOSTAGENT_WATCHER_SERVICE \
  SETUP_MACHINE_SCRIPT

# generate cloud-init
if [[ -f ${CLOUDINIT} ]]; then
  echo "Cloud-init already generated!!!"
else
  echo "Generating cloud-init..."

  cp -f config/cloud-init.yaml "${CLOUDINIT}"

  yq -i '.users[].ssh_authorized_keys[0] = env(SSH_PUB_KEY)' "${CLOUDINIT}"
  # yq -i '.ca_certs.trusted[0] = load_str(env(CA_CERT_FILE))' "${CLOUDINIT}"
  yq -i '(.. | select(tag == "!!str")) |= envsubst(nu)' "${CLOUDINIT}"
fi
