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

: "${CONFIG_FILE:="hack/kubernetes/cluster.yaml"}"

source scripts/load-env.sh

# create multipass vm
multipass launch jammy \
  -c "${MULTIPASS_CPU_COUNT}" \
  -m "${MULTIPASS_MEM_SIZE_GB}g" \
  -d "${MULTIPASS_DISK_SIZE_GB}g" \
  -n kubernetes

CLUSTER_NAME="kubernetes"
K0S_IPADDR="$(multipass info kubernetes | awk '/IPv4/ { print $2 }')"
SSH_PUB_KEY_FILE="${HOME}/.ssh/id_ed25519.pub"
K0S_USERNAME=ubuntu
export \
  CLUSTER_NAME \
  K0S_IPADDR \
  SSH_PUB_KEY_FILE \
  K0S_USERNAME

# generate k0s config
gen_config_k0s /tmp/k0s.yaml

# generate k0sctl config
gen_config_k0sctl "${CONFIG_FILE}"

# FIXME: create cluster with k0sctl
k0sctl apply --config "${CONFIG_FILE}"

# deploy workload
kustomize build deployment/site/codecloud >/tmp/codecloud.yaml
kubectl apply -f /tmp/codecloud.yaml
