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

: "${CLUSTER_NAME:="sandbox"}"
: "${CONFIG_FILE:="hack/kind.yaml"}"

source scripts/load-env.sh

cp -f config/kind.yaml "${CONFIG_FILE}"
yq -i '.networking.disableDefaultCNI = true' "${CONFIG_FILE}"

# create kind cluster
create_kind_cluster "${CLUSTER_NAME}" "${CONFIG_FILE}"

# install cilium
install_cilium

# install flux
install_flux

# deploy workload
kustomize build deployment/site/sandbox/secrets >"hack/${CLUSTER_NAME}-secrets.yaml"
kustomize build deployment/site/sandbox/network >"hack/${CLUSTER_NAME}-network.yaml"
kustomize build deployment/site/sandbox >"hack/${CLUSTER_NAME}.yaml"

kubectl apply -f "hack/${CLUSTER_NAME}-secrets.yaml"
kubectl apply -f "hack/${CLUSTER_NAME}-network.yaml"
kubectl apply -f "hack/${CLUSTER_NAME}.yaml"
