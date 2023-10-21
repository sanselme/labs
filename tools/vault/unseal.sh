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

# init vault
initialize() {
  echo 'initializing vault...'

  vault operator init \
    -key-shares=10 \
    -key-threshold=3 \
    -format=json >/opt/vault/vault-credentials.json
}

# unseal vault
unseal() {
  echo 'unsealing vault...'

  UNSEAL_KEY_1="$(cat /opt/vault/vault-credentials.json | tail -n +3 | head -n 1 | tr -d ',' | tr -d '"')"
  UNSEAL_KEY_2="$(cat /opt/vault/vault-credentials.json | tail -n +4 | head -n 1 | tr -d ',' | tr -d '"')"
  UNSEAL_KEY_3="$(cat /opt/vault/vault-credentials.json | tail -n +5 | head -n 1 | tr -d ',' | tr -d '"')"

  vault operator unseal "${UNSEAL_KEY_1}"
  vault operator unseal "${UNSEAL_KEY_2}"
  vault operator unseal "${UNSEAL_KEY_3}"
}

# login vault
login() {
  echo 'logging into vault...'

  ROOT_TOKEN="$(cat /opt/vault/vault-credentials.json | awk '/root_token/ { print $2 }' | tr -d ',' | tr -d '"')"
  vault login "${ROOT_TOKEN}"
}

# save vault credentials
save() {
  echo 'saving vault credentials...'

  vault kv put kv/vault-credentials \
    root_token="${ROOT_TOKEN}" \
    unseal_key_1="${UNSEAL_KEY_1}" \
    unseal_key_2="${UNSEAL_KEY_2}" \
    unseal_key_3="${UNSEAL_KEY_3}" \
    vault_credentials_json="$(cat /opt/vault/vault-credentials.json)"
}

INIT_STATUS=$(vault status | awk '/Initialized/ { print $2 }' | tr -d ',' | tr -d '"')
SEAL_STATUS=$(vault status | awk '/Sealed/ { print $2 }' | tr -d ',' | tr -d '"')

[[ ${INIT_STATUS} == 'false' ]] && initialize
[[ ${SEAL_STATUS} == 'true' ]] && unseal

login

VAULT_KV_STATUS=$(vault secrets list | awk /kv/)
[[ -z ${VAULT_KV_STATUS} ]] && vault secrets enable -version=2 kv

VAULT_KV_SECRET_STATUS=$(vault kv list kv/ | awk /vault-credentials/)
[[ -z ${VAULT_KV_SECRET_STATUS} ]] && save

# TODO: upload to onepassword if requested
[[ -n ${UPLOAD} ]] &&
  scripts/onepassword/op-save-file.sh '' "vault-${SITE_NAME}" vault-credentials.json

# cleanup if requested
[[ -n ${CLEANUP} ]] &&
  rm -f /opt/vault/vault-credentials.json

echo 'vault initialized and unsealed'
