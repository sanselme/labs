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

# install package
snap install lxd microceph

# bootstrap microceph
microceph init

# configure microceph
ceph mgr module enable test_orchestrator
ceph orch set backend test_orchestrator
ceph osd pool create cephfs_data
ceph osd pool create cephfs_metadata
ceph fs new cephfs cephfs_metadata cephfs_data
ceph fs subvolume create cephfs microceph
ceph fs subvolume getpath cephfs

# init lxd
lxd init

# TODO: add lxd to MAAS
