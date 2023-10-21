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

IMAGES=(
  clos
  inception
)

: "${REPO:=ghcr.io/sanselme/labs}"
: "${TAG:=v0.1.0}"

# build and push image
for image in "${IMAGES[@]}"; do
  CID="$(docker container create --cap-add SYS_ADMIN --device /dev/loop0 -v "${PWD}:/os:rw" -it "${IMG}:${TAG}" /bin/bash)"
  IMG_SIZE="$(expr 1024 \* 1024 \* 1024)"
  IMG="${REPO}/${image}"
  OFFSET=$(expr 512 \* 2048)

  # export image
  docker export -o "${image}.tgz" "${CID}"
  tar -tzf "${image}.tgz" | grep -E '^[^/]*/?$'

  # create partition
  docker container start "${CID}"
  docker container exec -it "${CID}" dd if=/dev/zero of="/os/${image}.img" bs="${IMG_SIZE}" count=1
  docker container exec -it "${CID}" sfdisk "/os/${image}.img" <<EOF
label: dos
label-id: 0x5d8b75fc
device: new.img
unit: sectors

${image}.img1 : start=2048, size=2095104, type=83, bootable
EOF

  # format image
  docker container exec -it "${CID}" losetup -o "${OFFSET}" /dev/loop0 "/os/${image}.img"
  docker container exec -it "${CID}" mkfs.ext3 /dev/loop0
  docker container exec -it "${CID}" mkdir /os/mnt
  docker container exec -it "${CID}" mount -t auto /dev/loop0 /os/mnt/
  docker container exec -it "${CID}" tar -xvf "/os/${image}.tgz" -C /os/mnt/

  # install bootloader
  docker container exec -it "${CID}" apt-get update -y
  docker container exec -it "${CID}" apt-get install -y extlinux

  docker container exec -it "${CID}" extlinux --install /os/mnt/boot/
  docker container exec -it "${CID}" cat >/os/mnt/boot/syslinux.cfg <<EOF
DEFAULT linux
  SAY Now booting the kernel from SYSLINUX...
 LABEL linux
  KERNEL /vmlinuz
  APPEND ro root=/dev/sda1 initrd=/initrd.img
EOF

  docker container exec -it "${CID}" dd if=/usr/lib/syslinux/mbr/mbr.bin of="/os/${image}.img" bs=440 count=1 conv=notrunc

  docker container exec -it "${CID}" umount /os/mnt
  docker container exec -it "${CID}" losetup -D

  # TODO: sign image
done
