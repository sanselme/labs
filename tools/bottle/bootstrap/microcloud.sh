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

# load environment variables
source ./scripts/load-env.sh

# configure machine
./scripts/setup-machine.sh

# install packages
snap install lxd microceph

# bootstrap microceph
microceph init

# configure microceph
ceph osd pool create cephfs_data
ceph osd pool create cephfs_metadata
ceph fs new cephfs cephfs_metadata cephfs_data
# ceph fs subvolumegroup create cephfs lxd
# ceph fs subvolumegroup getpath cephfs lxd

ceph mgr module enable test_orchestrator
ceph orch set backend test_orchestrator

ceph mgr module enable dashboard
ceph dashboard set-ssl-certificate -i tls.crt
ceph dashboard set-ssl-certificate-key -i tls.key
ceph config set mgr mgr/dashboard/ssl_server_port 8443
ceph dashboard ac-user-create admin -i passwd administrator
ceph dashboard set-rgw-credentials

# TODO: enable ssl for ceph rgw

# Otional: enable lxd
# lxd init

# add lxd to MAAS
# TODO: add lxd to MAAS

# Optional: enable sunbeam
