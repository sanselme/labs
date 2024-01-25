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

export NS="${2:-default}"

DESTINATION="build/site/${TARGET_CLUSTER_NAME}"
BOOTSTRAP_KUBECONFIG_CONF="${3:-${DESTINATION}/bootstrap-kubeconfig.conf}"
BOOTSTRAP_KUBECONFIG_YAML="${3:-${DESTINATION}/bootstrapkubeconfig.yaml}"

# generate bootstrap-kubeconfig.yaml & apply it to mgmt cluster
cp -f deployment/global/capi/template/bootstrapkubeconfig.yaml "${BOOTSTRAP_KUBECONFIG_YAML}"

NAME="bootstrap-${TARGET_CLUSTER_NAME}" yq -i '.metadata.name = env(NAME)' "${BOOTSTRAP_KUBECONFIG_YAML}"
yq -i 'del(.spec.insecure-skip-tls-verify)' "${BOOTSTRAP_KUBECONFIG_YAML}"
yq -i '.spec.apiserver = env(APISERVER)' "${BOOTSTRAP_KUBECONFIG_YAML}"
yq -i '.metadata.namespace = env(NS)' "${BOOTSTRAP_KUBECONFIG_YAML}"
yq -i '.spec.certificate-authority-data = env(CA_CERT)' "${BOOTSTRAP_KUBECONFIG_YAML}"

kubectl create namespace "${NS}" --dry-run=client -o=yaml | kubectl apply -f -
kubectl apply -n "${NS}" -f "${BOOTSTRAP_KUBECONFIG_YAML}"

# FIXME: generate bootstrap-kubeconfig.conf
sleep 15
kubectl get bootstrapkubeconfig "bootstrap-${CLUSTER_NAME}" \
  -n "${NS}" \
  -o=jsonpath='{.status.bootstrapKubeconfigData}' \
  >"${BOOTSTRAP_KUBECONFIG_CONF}"
