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

: "${DOCKER_COMPOSE_FILE:="hack/docker/docker-compose.yaml"}"

# generate cluster config
k0s-generate-config.sh hack/docker/cluster.yaml

# docker-compose up
docker-compose -f "${DOCKER_COMPOSE_FILE}" up -d --wait

# export kubeconfig
docker-compose -f "${DOCKER_COMPOSE_FILE}" exec k0s cat /var/lib/k0s/pki/admin.conf >"hack/docker/kubeconfig.yaml"

# apply lbpool & l2announcement
if [[ $(cilium status | grep OK | wc -l | tr -d " ") -gt 2 ]]; then
  kubectl apply -f hack/lbpool.yaml
  kubectl apply -f hack/l2announcement.yaml
fi

# deploy workload
kustomize build deployment/site/wordpress >/tmp/wordpress.yaml
kubectl apply -f /tmp/wordpress.yaml
