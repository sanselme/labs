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

: "${CEPH_REPO:="$(yq '.spec.url' deployment/global/csi/ceph/rook/source.yaml)"}"
: "${CEPH_VERSION:="$(yq '.spec.chart.spec.version' deployment/global/csi/ceph/rook/operator.yaml)"}"
: "${CLUSTER_NAME:="rook-ceph"}"
: "${CONFIG_FILE:="/tmp/kind.yaml"}"
: "${CONTAINER_NAME:="${CLUSTER_NAME}-control-plane"}"

CURRENT_DIR="$(dirname "${0}")"
source "${CURRENT_DIR}/kind-cilium.sh"

cp -f config/kind.yaml "${CONFIG_FILE}"
yq -i '.networking.disableDefaultCNI = true' "${CONFIG_FILE}"

# create loopback device
docker container cp scripts/setup-ceph-loopdev.sh "${CONTAINER_NAME}:setup-ceph-loopdev.sh"
docker container exec -it "${CONTAINER_NAME}" chmod +x /setup-ceph-loopdev.sh
docker container exec -it "${CONTAINER_NAME}" /setup-ceph-loopdev.sh

# generate rook-ceph manifests
kustomize build deployment/profile/carrier/ceph >/tmp/rook-ceph.yaml

# deploy rook-ceph
yq 'select(.kind == "HelmRelease") | select(.metadata.name == "rook-ceph-operator") | .spec.values' /tmp/rook-ceph.yaml >/tmp/values.yaml
yq -i '.allowLoopDevices=true' /tmp/values.yaml
helm upgrade rook-ceph \
  --create-namespace \
  --install rook-ceph \
  --namespace rook-ceph \
  --repo "${CEPH_REPO}" \
  --values /tmp/values.yaml \
  --version "${CEPH_VERSION}"

# configure snapshotter
yq 'select(.kind == "GitRepository")' /tmp/rook-ceph.yaml | kubectl apply -f -
yq 'select(.kind == "Kustomization")' /tmp/rook-ceph.yaml | kubectl apply -f -

# deploy rook-ceph cluster
yq 'select(.kind == "HelmRelease") | select(.metadata.name == "rook-ceph-cluster") | .spec.values' /tmp/rook-ceph.yaml >/tmp/values.yaml
yq -i '.cephClusterSpec.storage.useAllDevices=false' /tmp/values.yaml
yq -i '.cephClusterSpec.storage.devices[0].name="/dev/loop101"' /tmp/values.yaml
yq -i '.cephClusterSpec.storage.devices[1].name="/dev/loop102"' /tmp/values.yaml
yq -i '.cephClusterSpec.storage.devices[2].name="/dev/loop103"' /tmp/values.yaml
helm upgrade rook-ceph-cluster \
  --install rook-ceph-cluster \
  --namespace rook-ceph \
  --repo "${CEPH_REPO}" \
  --values /tmp/values.yaml \
  --version "${CEPH_VERSION}"
kubectl annotate storageclass ceph-block storageclass.kubernetes.io/is-default-class="false" --overwrite

# configure rook-ceph
NS="rook-ceph"
POD="$(kubectl get pod -n "${NS}" | awk '/rook-ceph-tools/ { print $1 }')"

sleep 15
kubectl exec -n "${NS}" "${POD}" -- ceph mgr module enable rook
kubectl exec -n "${NS}" "${POD}" -- ceph orch set backend rook
