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
source .env

# create kind cluster
./tools/kind-cluster.sh

# prepare loop devices for ceph cluster
./tools/kind-prepare-ceph.sh
docker container exec -it "${CLUSTER_NAME}-control-plane" lsblk

# check cluster
kubectl cluster-info
kubectl get node -o wide
kubectl get pod -A -o wide
helm ls -A

# label nodes
kubectl label node --all ucp-control-plane=enabled

# bootstrap flux
./tools/sops/apply.sh cicd
./tools/flux/bootstrap.sh main maas
