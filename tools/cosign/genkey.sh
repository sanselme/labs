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
source .env

cd build/

# generate key pair
COSIGN_PASSWORD="" \
  echo y | cosign generate-key-pair

# FIXME: save private key to onepassword
# scripts/onepassword/op-save-file.sh "${COSIGN_KEY}" "${COSIGN_KEY_OP_TITLE}" cosign.key
