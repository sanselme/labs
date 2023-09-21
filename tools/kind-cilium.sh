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

: "${CLUSTER_NAME:="cilium"}"
: "${CONFIG_FILE:="/tmp/kind.yaml"}"

source scripts/load-env.sh

cp -f config/kind.yaml "${CONFIG_FILE}"
yq -i '.networking.disableDefaultCNI = true' "${CONFIG_FILE}"

# create kind cluster
create_kind_cluster "${CLUSTER_NAME}" "${CONFIG_FILE}"

# install cilium
CILIUM_STATUS_COUNT="$(cilium status | grep OK | wc -l | tr -d " ")"
[[ ${CILIUM_STATUS_COUNT} -lt 2 ]] &&
  cilium install \
    --version "${CILIUM_VERSION}" \
    --wait && sleep 15

kubectl apply -f hack/lbpool.yaml
kubectl apply -f hack/l2announcement.yaml

# deploy workload
kustomize build deployment/profile/common >"/tmp/${CLUSTER_NAME}.yaml"
kubectl apply -f "/tmp/${CLUSTER_NAME}.yaml"
