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

: "${CEPH_LOOPDEV_SIZE_MB:="10240"}"

# verify dependencies are installed
[[ -z $(command -v dd) ]] && echo "dd is not installed" && exit 1
[[ -z $(command -v losetup) ]] && echo "losetup is not installed" && exit 1

for i in {1..3}; do
  # create raw devices if they don't exist
  [[ -s "rook-ceph-${i}.img" ]] && echo "raw device already exists" ||
    dd if=/dev/zero of="rook-ceph-${i}.img" bs=1M count="${CEPH_LOOPDEV_SIZE_MB}"

  # create loop devices if they don't exist
  [[ -b "/dev/loop${i}" ]] && echo "loop device already exists" ||
    losetup "/dev/loop${i}" "rook-ceph-${i}.img"
done
