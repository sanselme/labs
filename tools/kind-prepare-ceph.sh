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
source scripts/load-env.sh

: "${CEPH_REPO:="$(yq '.spec.url' deployment/global/csi/ceph/rook/source.yaml)"}"
: "${CEPH_VERSION:="$(yq '.spec.chart.spec.version' deployment/global/csi/ceph/rook/operator.yaml)"}"
: "${CONTAINER_NAME:="${CLUSTER_NAME}-control-plane"}"

# create loopback device
docker container cp scripts/setup-ceph-loopdev.sh "${CONTAINER_NAME}:setup-ceph-loopdev.sh"
docker container exec -it "${CONTAINER_NAME}" chmod +x /setup-ceph-loopdev.sh
docker container exec -it "${CONTAINER_NAME}" /setup-ceph-loopdev.sh

# FIXME: configure rook-ceph
# NS="rook-ceph"
# POD="$(kubectl get pod -n "${NS}" | awk '/rook-ceph-tools/ { print $1 }')"

# sleep 15
# kubectl exec -n "${NS}" "${POD}" -- ceph mgr module enable rook
# kubectl exec -n "${NS}" "${POD}" -- ceph orch set backend rook
