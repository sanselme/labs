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

CILIUM_VERSION="$(yq '.spec.chart.spec.version' deployment/global/cni/cilium/release.yaml)"
FLUX_VERSION="$(yq '.spec.chart.spec.version' deployment/global/sre/flux/release.yaml)"
export CILIUM_VERSION FLUX_VERSION

export CLUSTER_NAME="sandbox"
export CONFIG_FILE="hack/kind.yaml"

export BITNAMI="oci://registry-1.docker.io/bitnamicharts"

# verify dependencies are installed
CILIUM_CMD="$(command -v cilium)"
DOCKER_CMD="$(command -v docker)"
HELM_CMD="$(command -v helm)"
KIND_CMD="$(command -v kind)"
KUBECTL_CMD="$(command -v kubectl)"

[[ -z ${CILIUM_CMD} ]] && echo "cilium is not installed" && exit 1
[[ -z ${DOCKER_CMD} ]] && echo "docker is not installed" && exit 1
[[ -z ${HELM_CMD} ]] && echo "helm is not installed" && exit 1
[[ -z ${KIND_CMD} ]] && echo "kind is not installed" && exit 1
[[ -z ${KUBECTL_CMD} ]] && echo "kubectl is not installed" && exit 1

# create kind config if not present
create_kind_config() {
  DEFAULT_CNI=${1}
  [[ -z ${DEFAULT_CNI} ]] && DEFAULT_CNI=true

  [[ ! -f ${CONFIG_FILE} ]] && cp -f config/kind.yaml "${CONFIG_FILE}"
  [[ -n ${DEFAULT_CNI} ]] && yq -i '.networking.disableDefaultCNI = true' "${CONFIG_FILE}"
}

# create kind cluster if not present
create_kind_cluster() {
  CLUSTER_NAME="${CLUSTER_NAME:-$1}"
  CLUSTER_CONFIG="${CLUSTER_CONFIG:-$2}"

  [[ -z ${CLUSTER_NAME} ]] && export CLUSTER_NAME="kind"

  if [[ -z $(kind get clusters | grep "${CLUSTER_NAME}") ]]; then
    echo "Creating kind cluster ${CLUSTER_NAME}..."
    if [[ -z ${CLUSTER_CONFIG} ]]; then
      kind create cluster --name "${CLUSTER_NAME}"
    else
      kind create cluster --name "${CLUSTER_NAME}" --config "${CLUSTER_CONFIG}"
    fi
    sleep 15
  fi

  kubectl cluster-info
  kubectl get node -o wide
  kubectl get pod -o wide -A
}

# install cilium
install_cilium() {
  CILIUM_STATUS_COUNT="$(cilium status | grep -c OK | tr -d ' ')"

  # FIXME: do we need this
  # CILIUM_VALUES="${1}"
  # [[ -z ${CILIUM_VALUES} ]] && CILIUM_VALUES=""

  [[ ${CILIUM_STATUS_COUNT} -lt 2 ]] &&
    cilium install \
      --values "${CILIUM_VALUES}" \
      --version "${CILIUM_VERSION}" \
      --wait && sleep 15 || echo "Cilium is already installed!!!"
}

# install flux
install_flux() {
  helm upgrade flux \
    --create-namespace \
    --install "${BITNAMI}/flux" \
    --namespace sre \
    --version "${FLUX_VERSION}"
}
