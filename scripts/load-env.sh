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

CERT_MANAGER_VERSION="$(yq 'select(.kind == "HelmRelease") | select(.metadata.name == "cert-manager") | .spec.chart.spec.version' deployment/global/certmanager/release.yaml)"
CILIUM_VERSION="$(cilium install --list-versions | head -n 1 | awk '{print $1}')"
K0SMOTRON_VERSION="$(yq '.spec.k0s.version' config/k0s/k0sctl.tpl)"
ROOK_CEPH_VERSION="$(yq '.spec.chart.spec.version' deployment/global/csi/ceph/rook/operator.yaml)"
export CERT_MANAGER_VERSION CILIUM_VERSION K0SMOTRON_VERSION ROOK_CEPH_VERSION

APISERVER="$(kubectl config view -ojsonpath='{.clusters[0].cluster.server}')"
ARCH="$(uname -m)"
CA_CERT="$(kubectl config view --flatten -ojsonpath='{.clusters[0].cluster.certificate-authority-data}')"
export APISERVER ARCH CA_CERT

: "${SSH_PUB_KEY_FILE:="hack/multipass/id_ed25519.pub"}"

: "${MULTIPASS_CPU_COUNT:=2}"
: "${MULTIPASS_DISK_SIZE_GB:=64}"
: "${MULTIPASS_MEM_SIZE_GB:=8}"

: "${TIMEZONE:="America/Toronto"}"
: "${NTP_SERVERS:=("0.ca.pool.ntp.org" "1.ca.pool.ntp.org" "2.ca.pool.ntp.org" "3.ca.pool.ntp.org")}"

# verify dependencies are installed
[[ -z $(command -v cilium) ]] && echo "cilium is not installed" && exit 1
[[ -z $(command -v clusterctl) ]] && echo "clusterctl is not installed" && exit 1
[[ -z $(command -v docker) ]] && echo "docker is not installed" && exit 1
[[ -z $(command -v helm) ]] && echo "helm is not installed" && exit 1
[[ -z $(command -v kind) ]] && echo "kind is not installed" && exit 1
[[ -z $(command -v kubectl) ]] && echo "kubectl is not installed" && exit 1

# create kind cluster if not present
create_kind_cluster() {
  CLUSTER_NAME="${CLUSTER_NAME:-$1}"
  CLUSTER_CONFIG="${CLUSTER_CONFIG:-$2}"

  [[ -z ${CLUSTER_NAME} ]] && export CLUSTER_NAME="kind"

  if [[ -z $(kind get clusters | grep ${CLUSTER_NAME}) ]]; then
    echo "Creating kind cluster ${CLUSTER_NAME}..."
    [[ -z ${CLUSTER_CONFIG} ]] &&
      kind create cluster --name "${CLUSTER_NAME}" ||
      kind create cluster --name "${CLUSTER_NAME}" --config "${CLUSTER_CONFIG}"
    sleep 15
  fi

  kubectl cluster-info
  kubectl get node -o wide
  kubectl get pod -o wide -A
}

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

# generate k0sctl config
gen_config_k0sctl() {
  K0SCTL_CONFIG_FILE="${1}"
  [[ -z ${K0SCTL_CONFIG_FILE} ]] && echo "Usage: $0 <k0sctl-config-file>" && exit 1

  cp -f config/k0s/k0sctl.tpl "${K0SCTL_CONFIG_FILE}"
  yq -i 'del(.spec.api.externalAddress)' "${K0SCTL_CONFIG_FILE}"
  yq -i '(.. | select(tag == "!!str")) |= envsubst(nu)' "${K0SCTL_CONFIG_FILE}"
}
