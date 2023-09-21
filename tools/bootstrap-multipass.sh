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

CLOUD_INIT_FILE="hack/multipass/cloud-init.yaml"
cp -f config/cloud-init.yaml "${CLOUD_INIT_FILE}"

NAME="skiff"

# generate byoh-bootstrap config
./scripts/byoh-generate-config.sh "${NAME}"

# generate ssh key if not provided
[[ ! -f ${SSH_PUB_KEY_FILE} ]] && ssh-keygen -N "" -t ed25519 -C "${NAME}" -f hack/multipass/id_ed25519
SSH_PUB_KEY="$(cat "${SSH_PUB_KEY_FILE}")"
export SSH_PUB_KEY

# generate certificate authority if not provided
if [[ -z ${CA_CERT_FILE} ]]; then
  [[ ! -f hack/multipass/ca.crt ]] &&
    openssl genrsa -out hack/multipass/ca.key 2048 &&
    openssl req -x509 -new -nodes -key hack/multipass/ca.key -days 10000 -out hack/multipass/ca.crt -subj "/CN=ca"
  export CA_CERT_FILE="hack/multipass/ca.crt"
fi

# update cloud-init with bootstrap config
BOOTSTRAP_KUBECONFIG="$(cat "${BOOTSTRAP_KUBECONFIG_FILE}")"
BYOH_HOSTAGENT_SERVICE="$(cat deployment/baremetal/byoh-hostagent.service)"
BYOH_HOSTAGENT_WATCHER_PATH="$(cat deployment/baremetal/byoh-hostagent-watcher.path)"
BYOH_HOSTAGENT_WATCHER_SERVICE="$(cat deployment/baremetal/byoh-hostagent-watcher.service)"
SETUP_MACHINE_SCRIPT="$(cat scripts/setup-machine.sh)"
export BOOTSTRAP_KUBECONFIG BYOH_HOSTAGENT_SERVICE BYOH_HOSTAGENT_WATCHER_PATH BYOH_HOSTAGENT_WATCHER_SERVICE SETUP_MACHINE_SCRIPT

extrafile_content="$(cat scripts/setup-ceph-loopdev.sh)"
extrafile='{path: /opt/setup-ceph-loopdev.sh, permissions: 0755, owner: root, content: $extrafile_content}'
export extrafile_content extrafile

yq -i '.users[].ssh_authorized_keys = env(SSH_PUB_KEY)' "${CLOUD_INIT_FILE}"
yq -i '.ca_certs.trusted[0] = load_str(env(CA_CERT_FILE))' "${CLOUD_INIT_FILE}"
yq -i '.runcmd += "/opt/setup-ceph-loopdev.sh"' "${CLOUD_INIT_FILE}"
yq -i '.runcmd += "sudo systemctl enable --now byoh-hostagent.service"' "${CLOUD_INIT_FILE}"
yq -i '.runcmd += "sudo systemctl enable --now byoh-hostagent-watcher.path"' "${CLOUD_INIT_FILE}"
yq -i '.write_files += env(extrafile)' "${CLOUD_INIT_FILE}"
yq -i '(.. | select(tag == "!!str")) |= envsubst(nu)' "${CLOUD_INIT_FILE}"

# add bootstrap-kubeconfig ca cert to cloud-init
BOOTSTRAP_KUBECONFIG_CA_CERT="$(yq '.clusters[0].cluster.certificate-authority-data' "${BOOTSTRAP_KUBECONFIG_FILE}" | base64 -d)"
export BOOTSTRAP_KUBECONFIG_CA_CERT
yq -i '.ca_certs.trusted[1] = "'"${BOOTSTRAP_KUBECONFIG_CA_CERT}"'"' "${CLOUD_INIT_FILE}"

# create multipass vm with cloud-init
MULTIPASS_NETWORK="${1}"
[[ -z ${MULTIPASS_NETWORK} ]] && echo "MULTIPASS_NETWORK is not set" && exit 1

MULTIPASS_NAME_PREFIX="mpsb"
for i in {1..3}; do
  multipass launch jammy \
    --cloud-init "${CLOUD_INIT_FILE}" \
    --network "${MULTIPASS_NETWORK}" \
    -c "${MULTIPASS_CPU_COUNT}" \
    -m "${MULTIPASS_MEM_SIZE_GB}g" \
    -d "${MULTIPASS_DISK_SIZE_GB}g" \
    -n "${MULTIPASS_NAME_PREFIX}-0${i}" || continue
done

multipass ls
for i in {1..3}; do
  # upload byoh-agent
  multipass transfer "bin/byoh-hostagent" "${MULTIPASS_NAME_PREFIX}-0${i}":byoh-hostagent
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- sudo mv byoh-hostagent /usr/local/bin/byoh-hostagent
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- sudo systemctl restart byoh-hostagent.service

  # update netplan
  NETPLAN_FILE="hack/multipass/50-cloud-init.${MULTIPASS_NAME_PREFIX}-0${i}.yaml"

  cp -f config/custom-networking.tpl "${NETPLAN_FILE}"
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- cat /etc/netplan/50-cloud-init.yaml >/tmp/50-cloud-init.${MULTIPASS_NAME_PREFIX}-0${i}.yaml

  OAM_MACADDR="$(yq '.network.ethernets.default.match.macaddress' /tmp/50-cloud-init.${MULTIPASS_NAME_PREFIX}-0${i}.yaml)"
  ETH1_MACADDR="$(yq '.network.ethernets.extra0.match.macaddress' /tmp/50-cloud-init.${MULTIPASS_NAME_PREFIX}-0${i}.yaml)"
  export OAM_MACADDR ETH1_MACADDR

  yq -i 'del(.network.bonds.bond0.macaddress)' "${NETPLAN_FILE}"
  yq -i 'del(.network.bonds.bond0.interfaces[1])' "${NETPLAN_FILE}"
  yq -i 'del(.network.ethernets.oam.wakeonlan)' "${NETPLAN_FILE}"
  yq -i 'del(.network.ethernets.oam.addresses)' "${NETPLAN_FILE}"
  yq -i 'del(.network.ethernets.oam.routes)' "${NETPLAN_FILE}"
  yq -i 'del(.network.ethernets.eth2)' "${NETPLAN_FILE}"
  yq -i 'del(.network.ethernets.swp1)' "${NETPLAN_FILE}"
  yq -i 'del(.network.ethernets.swp2)' "${NETPLAN_FILE}"
  yq -i '.network.ethernets.oam.match.macaddress = env(OAM_MACADDR)' "${NETPLAN_FILE}"
  yq -i '.network.ethernets.eth1.match.macaddress = env(ETH1_MACADDR)' "${NETPLAN_FILE}"

  multipass transfer "${NETPLAN_FILE}" "${MULTIPASS_NAME_PREFIX}-0${i}":50-cloud-init.yaml
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- sudo mv 50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- sudo netplan generate
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- sudo netplan apply
  multipass exec "${MULTIPASS_NAME_PREFIX}-0${i}" -- networkctl
done

# deploy workload
kustomize build deployment/site/skiff >"/tmp/${MULTIPASS_NAME_PREFIX}.yaml"
kubectl apply -f "/tmp/${MULTIPASS_NAME_PREFIX}.yaml"
