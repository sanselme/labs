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

TARGET_CLUSTER_NAME="${1}"
[[ -z ${TARGET_CLUSTER_NAME} ]] && echo "Usage: $0 <target-cluster-name>" && exit 1

# generate bootstrap-kubeconfig.yaml & apply it to mgmt cluster
cp -f deployment/global/capi/template/bootstrapkubeconfig.yaml hack/kubernetes/bootstrap-kubeconfig.yaml

yq -i 'del(.spec.insecure-skip-tls-verify)' hack/kubernetes/bootstrap-kubeconfig.yaml
yq -i '.spec.apiserver = env(APISERVER)' hack/kubernetes/bootstrap-kubeconfig.yaml
yq -i '.spec.certificate-authority-data = env(CA_CERT)' hack/kubernetes/bootstrap-kubeconfig.yaml

kubectl apply -f hack/kubernetes/bootstrap-kubeconfig.yaml

# generate bootstrap-kubeconfig.conf
sleep 30
kubectl get bootstrapkubeconfig bootstrap-kubeconfig \
  -n default \
  -o=jsonpath='{.status.bootstrapKubeconfigData}' \
  >"${BOOTSTRAP_KUBECONFIG_FILE:-$2}"
