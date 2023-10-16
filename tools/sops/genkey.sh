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

# generate key pair
gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: "${KEY_COMMENT}"
Name-Real: "${KEY_NAME}"
EOF

PGP="$(gpg --list-keys "${KEY_NAME}" | head -n +2 | tail -n 1 | tr -d ' ')"
export PGP

# export public key
gpg --export --armor "${PGP}" >"${PUB_KEY}"

# generate sops config
cat <<EOF | envsubst | tee "${SOPS_CONFIG}"
creation_rules:
  - path_regex: .*.yaml
    encrypted_regex: ^(data|stringData|password|token)$
    pgp: ${PGP}
EOF
