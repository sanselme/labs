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

# install latest lxd
snap remove --purge lxd
snap install lxd

# generate preseed
cat <<EOF > /tmp/lxd.yaml
config:
  cluster.https_address: 10.0.0.1:8443
  # core.bgp_address=0.0.0.0:179
  # core.bgp_asn=65001
  # core.bgp_routerid=10.0.0.1
  core.https_address: 10.0.0.1:8443
  network.ovn.northbound_connection: ssl:10.0.0.1:6641
networks: []
storage_pools: []
profiles:
- config: {}
  description: ""
  devices: {}
  name: default
projects: []
cluster:
  server_name: sandbox
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""
  cluster_certificate_path: ""
  cluster_token: ""
EOF

# init lxd with preseed
lxd init --preseed /tmp/lxd.yaml

# configure ovn
lxc network create UPLINK --type=physical parent=external
lxc network set UPLINK  \
  ipv4.ovn.ranges=192.168.11.64-192.168.11.191 \
  ipv4.gateway=192.168.11.1/24 \
  dns.nameservers=1.1.1.1,9.9.9.9
lxc network create default --type=ovn network=UPLINK

# configure ceph
ceph osd pool create lxd
ceph osd pool application enable lxd rbd

ceph fs subvolumegroup create cephfs lxd
ceph fs subvolumegroup getpath cephfs lxd

# configure cephfs
lxc storage create default ceph source=lxd
lxc storage create shared cephfs source=cephfs/volumes/lxd

# configure profile
cat <<EOF > /tmp/profile.yaml
config: {}
description: Default LXD profile
devices:
  oam:
    name: oam
    network: default
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: default
used_by:
EOF
lxc profile edit default < /tmp/profile.yaml

# enable gui
snap set lxd ui.enable=true
sudo systemctl reload snap.lxd.daemon
lxc config trust add --name lxd-ui

# FIXME: register to maas
# lxc config trust add - <<EOF
# -----BEGIN CERTIFICATE-----

# -----END CERTIFICATE-----
# EOF
