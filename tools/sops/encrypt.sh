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

DIR="${1}"
[[ -z ${DIR} ]] && echo "no directory provided" && exit 1

FILES="$(find "${DIR}" -type f -name "*.yaml" ! -name kustomization.yaml)"
[[ -z ${FILES} ]] && echo "no files found" && exit 1

# encrypts file with sops
echo "encrypting files in ${DIR}..."
for file in ${FILES[@]}; do
  sops \
    --encrypt \
    --config "${SOPS_CONFIG}" \
    --in-place "${file}" \
    --pgp "${PGP}"
done
