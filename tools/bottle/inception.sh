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

: "${APPROLE_ID:=maas}"
: "${EMAIL_ADDRESS:=none@none}"
: "${MAAS_POLICY:=maas}"
: "${MAAS_URL:=http://localhost:5420/MAAS}"
: "${POLICY_FILE:=policy.hcl}"
: "${PROFILE:=admin}"
: "${ROLE_NAME:=maas}"
: "${SECRETS_MOUNT:=maas}"
: "${SECRETS_PATH:=infra}"

# Configure Vault
systemctl enable vault.service

# Install MAAS
apt-add-repository ppa:maas/3.4-next
apt update
apt-get -y install maas

# Configure MAAS
systemctl disable systemd-timesyncd
maas createadmin --username="${PROFILE}" --email="${EMAIL_ADDRESS}"
maas status
maas init region
maas apikey --username="${PROFILE}" >api-key-file
maas login "${PROFILE}" "${MAAS_URL}" <api-key-file
maas "${PROFILE}" maas set-config name=upstream_dns value="1.1.1.1 9.9.9.9"
maas "${PROFILE}" boot-source-selections create 1 os="ubuntu" release="trusty" arches="amd64" subarches="*" labels="*"
maas "${PROFILE}" boot-resources read | jq -r '.[] | "\(.name)\t\(.architecture)"'
maas admin boot-resources import
maas "${PROFILE}" subnet read "${SUBNET_CIDR}" | grep fabric_id
maas "${PROFILE}" rack-controllers read | grep hostname | cut -d '"' -f 4
maas "${PROFILE}" vlan update "${FABRIC_ID}" untagged dhcp_on=True primary_rack="${RACK_CONTR_HOSTNAME}"
