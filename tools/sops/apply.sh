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

NAMESPACE="${1}"
[[ -z ${NAMESPACE} ]] && echo "Usage: $0 <namespace>" && exit 1

# FIXME: export secret key if not present on file and in gpg keystore
# gpg --export-secret-keys \
#   --armor sandbox |
#   tee "${SEC_KEY}"

# TODO: get secret key from onepassword otherwise

# create secret
kubectl create namespace "${NAMESPACE}" || echo "namespace already exists"
kubectl create secret generic sops-gpg \
  --dry-run=client \
  --from-file sops.asc="${SEC_KEY}" \
  --namespace "${NAMESPACE}" \
  --output yaml |
  kubectl apply -f -
