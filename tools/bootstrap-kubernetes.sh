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

# generate k0s config
k0s-generate-config.sh /tmp/k0s.yaml

# generate k0sctl config
k0sctl-generate-config.sh "${CONFIG_FILE}"

# create multipass vm
multipass launch jammy \
  -c "${MULTIPASS_CPU_COUNT}" \
  -m "${MULTIPASS_MEM_SIZE_GB}g" \
  -d "${MULTIPASS_DISK_SIZE_GB}g" \
  -n kubernetes

# create cluster with k0sctl
k0sctl apply --config "${CONFIG_FILE}"

# deploy workload
kustomize build deployment/site/codecloud >/tmp/codecloud.yaml
kubectl apply -f /tmp/codecloud.yaml
