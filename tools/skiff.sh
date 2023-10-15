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

# generate workload config
kustomize build deployment/site/skiff >"hack/${CLUSTER_NAME}.yaml"
kustomize build deployment/site/skiff/network >"hack/${CLUSTER_NAME}-network.yaml"
kustomize build deployment/site/skiff/secrets >"hack/${CLUSTER_NAME}-secrets.yaml"

# deploy workload
kubectl apply -f "hack/${CLUSTER_NAME}.yaml"
kubectl apply -f "hack/${CLUSTER_NAME}-network.yaml"
kubectl apply -f "hack/${CLUSTER_NAME}-secrets.yaml"
