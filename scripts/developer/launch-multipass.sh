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

NAME="${1}"
CLOUDINIT="${2}"
NET="${3}"
[[ -z ${NAME} || -z ${CLOUDINIT} ]] && {
  echo """
Usage: $0 <name> <cloud-init> [net]
  name:       name of the instance
  cloud-init: path to cloud-init file
  net:        network interface to use (default: none)

Example:
  $0 vision ~/Downloads/cloud-init.yaml
"""
  exit 1
}

: "${CPUS:=2}"
: "${DISK:=32}"
: "${MEM:=8}"

# decrypt cloud-init if provided
[[ -f ${CLOUDINIT} ]] && {
  ./tools/sops/decrypt.sh "${CLOUDINIT}"
}

# launch multipass
multipass launch \
  --cloud-init "${CLOUDINIT}" \
  --name "${NAME}" \
  --network "${NET}" \
  -c "${CPUS}" \
  -d "${DISK}g" \
  -m "${MEM}g"
