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

: "${CLUSTER_NAME:="bootstrap"}"

source scripts/load-env.sh

# generate cluster config
export ipaddr="${1:-$(docker network inspect kind | jq -r '.[0].IPAM.Config[0].Gateway')}"
export extraport='{containerPort: 30443, hostPort: 30443, listenAddress: 0.0.0.0, protocol: TCP}'

cp -f config/kind.yaml hack/kind.yaml

sed -i '' 's/extraMounts.*/extraMounts:/g' hack/kind.yaml
sed -i '' 's/#//g' hack/kind.yaml

yq -i '.nodes[].extraPortMappings += env(extraport)' hack/kind.yaml
yq -i '.networking.apiServerAddress = env(ipaddr)' hack/kind.yaml

# create kind cluster if not present
create_kind_cluster "${CLUSTER_NAME}" hack/kind.yaml

# install cilium if not present
CILIUM_STATUS_COUNT="$(cilium status | grep OK | wc -l | tr -d " ")"
if [[ ${CILIUM_STATUS_COUNT} -lt 2 ]]; then
  echo "Installing cilium..."
  cilium install --version "${CILIUM_VERSION}" --wait

  sleep 30
  kubectl apply -f hack/lbpool.yaml
  kubectl apply -f hack/l2announcement.yaml
fi

# install cert-manager if not present
CERT_MANAGER_STATUS_COUNT="$(kubectl get pods --namespace cert-manager | grep Running | wc -l | tr -d " ")"
if [[ ${CERT_MANAGER_STATUS_COUNT} -lt 3 ]]; then
  echo "Installing cert-manager..."
  helm upgrade cert-manager \
    --create-namespace \
    --install cert-manager \
    --namespace cert-manager \
    --repo https://charts.jetstack.io/ \
    --set installCRDs=true \
    --version "${CERT_MANAGER_VERSION}" \
    --wait
fi

# install capi
clusterctl init \
  --addon helm \
  --core cluster-api \
  --infrastructure docker \
  --infrastructure byoh \
  --wait-providers

# install k0smotron
kubectl apply -f "https://docs.k0smotron.io/${K0SMOTRON_VERSION}/install.yaml"

# deploy workload
kustomize build deployment/site/bootstrap >/tmp/bootstrap.yaml
kubectl apply -f /tmp/bootstrap.yaml
