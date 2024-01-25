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

# create multipass vm
multipass launch jammy \
  -c "${MULTIPASS_CPU_COUNT}" \
  -m "${MULTIPASS_MEM_SIZE_GB}g" \
  -d "${MULTIPASS_DISK_SIZE_GB}g" \
  -n kubernetes

# configure multipass vm
cat <<EOF >/tmp/config.sh
#!/bin/bash
set -e
cat authorized_keys | tee -a /home/ubuntu/.ssh/authorized_keys
rm -f authorized_keys config.sh
curl -sSLf https://get.k0s.sh | sudo sh
EOF
multipass transfer "${SSH_PUB_KEY_FILE}" kubernetes:authorized_keys
multipass transfer /tmp/config.sh kubernetes:config.sh
multipass exec kubernetes -- bash config.sh

CLUSTER_NAME=kubernetes
K0S_IPADDR="$(multipass info kubernetes | awk '/IPv4/ { print $2 }')"
K0S_USERNAME=ubuntu
export \
  CLUSTER_NAME \
  K0S_IPADDR \
  K0S_USERNAME

# generate k0s config
gen_config_k0s "${K0S_CONFIG_FILE}"

# generate k0sctl config
gen_config_k0sctl "${K0SCTL_CONFIG_FILE}"

# create cluster with k0sctl
k0sctl apply --config "${K0SCTL_CONFIG_FILE}"

# generate workload config
kustomize build deployment/site/codecloud >"hack/codecloud.yaml"
kustomize build deployment/site/codecloud/network >"hack/codecloud-network.yaml"
kustomize build deployment/site/codecloud/secrets >"hack/codecloud-secret.yaml"

# deploy workload
kubectl apply -f "hack/codecloud.yaml"
kubectl apply -f "hack/codecloud-network.yaml"
kubectl apply -f "hack/codecloud-secret.yaml"
