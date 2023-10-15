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

: "${DOCKER_COMPOSE_FILE:="hack/docker/docker-compose.yaml"}"

# generate cluster config
gen_config_k0s hack/docker/cluster.yaml

# docker-compose up
docker-compose -f "${DOCKER_COMPOSE_FILE}" up -d --wait

# export kubeconfig
sleep 15
docker-compose -f "${DOCKER_COMPOSE_FILE}" exec k0s cat /var/lib/k0s/pki/admin.conf >"hack/docker/kubeconfig.yaml"
export KUBECONFIG="hack/docker/kubeconfig.yaml"

# generate workload config
kustomize build deployment/site/wordpress >"hack/wordpress.yaml"
kustomize build deployment/site/wordpress/network >"hack/wordpress-network.yaml"
kustomize build deployment/site/wordpress/secrets >"hack/wordpress-secrets.yaml"

# deploy workload
kubectl apply -f "hack/wordpress.yaml"
kubectl apply -f "hack/wordpress-network.yaml"
kubectl apply -f "hack/wordpress-secrets.yaml"
