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

# get private key from onepassword
scripts/onepassword/op-get-privkey.sh "${SEC_KEY}" "${SEC_KEY_OP_TITLE}" .sops.asc

# import private key
gpg --armor --import --allow-secret-key-import "${SEC_KEY}"

# import public key
gpg --armor --import "${PUB_KEY}"
