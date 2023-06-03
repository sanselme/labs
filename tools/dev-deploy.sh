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

set -e pipefail
git stash || true

# TODO: determine if sandbox, kind or minikube should be used

# Create the cluster if it doesn't already exist
[[ -z $(kind get clusters | grep "${CLUSTER_NAME}") ]] &&
  kind create cluster \
    --name "${CLUSTER_NAME}" \
    --config "./build/site/${CLUSTER_NAME}/cluster.yaml" &&
  sleep 5

# Install Cilium
[[ -z $(helm ls -n kube-system | grep cilium) ]] &&
  helm upgrade cilium cilium \
    --install \
    --repo https://helm.cilium.io/ \
    --version 1.14.0-snapshot.4 \
    --namespace kube-system \
    --set operator.replicas=1 \
    --set kubeProxyReplacement=strict \
    --set l2announcements.enabled=true \
    --set externalIPs.enabled=true

# TODO: enable ceph if --enable-ceph is passed

# Deploy Flux
flux check --pre
flux bootstrap github \
  --recurse-submodules \
  --owner="${GITHUB_USER}" \
  --repository="${GITHUB_REPO:-labs}" \
  --branch="${GITHUB_BRANCH:-dev}" \
  --path="./build/site/${CLUSTER_NAME}/manifest" \
  --gpg-key-id="${FLUX_GPG_KEY_ID}" \
  --gpg-passphrase="${FLUX_GPG_PASSPHRASE}" \
  --components-extra="${FLUX_EXTRA_COMPONENTS}"

# Create the SOPS GPG key secret
gpg --export-secret-keys --armor "${FLUX_GPG_KEY_ID}" |
  kubectl create secret generic sops-gpg \
    --namespace flux-system \
    --from-file=sops.asc=/dev/stdin \
    --dry-run=client \
    -o yaml |
  kubectl apply -f -

# Clean up any changes made to the repo
sleep 1
git checkout .
git stash pop || true
