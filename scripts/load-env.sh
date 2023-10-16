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
export K0S_CONFIG_FILE="hack/kubernetes/k0s.yaml"
export K0SCTL_CONFIG_FILE="hack/kubernetes/cluster.yaml"
export SSH_PUB_KEY_FILE="${HOME}/.ssh/id_ed25519.pub"

export KEY_COMMENT="test key for sops"
export KEY_NAME="sandbox"
export PUB_KEY="${1:-build/.sops.pub.asc}"
export SEC_KEY="${2:-build/.sops.asc}"
export SOPS_CONFIG="${3:-build/.sops.yaml}"

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

# generate k0s config
gen_config_k0s() {
  K0S_CONFIG_FILE="${1}"
  [[ -z ${K0S_CONFIG_FILE} ]] && echo "Usage: $0 <k0s-config-file>" && exit 1

  cp -f config/k0s/k0s.tpl "${K0S_CONFIG_FILE}"
  sed -i '' 's/# //g' "${K0S_CONFIG_FILE}"

  yq -i 'del(.spec.api.externalAddress)' "${K0S_CONFIG_FILE}"
  yq -i 'del(.spec.api.extraArgs)' "${K0S_CONFIG_FILE}"
  yq -i '.metadata.name = "docker"' "${K0S_CONFIG_FILE}"
}

# FIXME: generate k0sctl config
gen_config_k0sctl() {
  K0SCTL_CONFIG_FILE="${1}"
  [[ -z ${K0SCTL_CONFIG_FILE} ]] && echo "Usage: $0 <k0sctl-config-file>" && exit 1

  cp -f config/k0s/k0sctl.tpl "${K0SCTL_CONFIG_FILE}"
  yq -i '(.. | select(tag == "!!str")) |= envsubst(nu)' "${K0SCTL_CONFIG_FILE}"

  yq -i '(.spec.k0s.config = load("hack/kubernetes/k0s.yaml"))' hack/kubernetes/cluster.yaml
  yq -i 'del(.spec.api.externalAddress)' "${K0SCTL_CONFIG_FILE}"
}

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
  NO_STANDARD_SC="${NO_STANDARD_SC:-$3}"

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

  # FIXME: remove sandard storageclass if requested
  if [[ -n ${NO_STANDARD_SC} ]]; then
    kubectl delete storageclass standard || echo "storageclass not found"
    kubectl delete deployment -n local-path-storage local-path-provisioner || echo "local-path-provisioner not found"
    kubectl delete namespaces local-path-storage || echo "local-path-storage not found"
  fi
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
  [[ -z "$(helm ls -n sre | awk /flux/)" ]] &&
    helm upgrade flux \
      --create-namespace \
      --install "${BITNAMI}/flux" \
      --namespace sre \
      --version "${FLUX_VERSION}" || echo "Flux is already installed!!!"
}
