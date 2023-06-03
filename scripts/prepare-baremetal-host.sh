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

: "${DOMAIN:="dev.local"}"
: "${INTERFACE:="bond0"}"
: "${LOCALE:="C.UTF-8"}"
: "${NAMESERVERS:="1.1.1.1 9.9.9.9"}"
: "${TIMEZONE:="America/Toronto"}"

# disable swap
swapoff -a
rm /swap.img || true
sed -i "/swap.img/d" /etc/fstab

# set locale
localectl set-locale LANG="${LOCALE}"

# set timezone
timedatectl set-ntp true
timedatectl set-timezone "${TIMEZONE}"

# set dns
resolvectl dns "${INTERFACE}" "${NAMESERVERS}"
resolvectl domain "${INTERFACE}" "${DOMAIN}"

# install packages
RELEASE="$(uname -r)"
apt-get update -y
apt-get install -y \
  "linux-modules-extra-${RELEASE}" \
  apparmor \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  jq \
  libcephfs2 \
  libseccomp2 \
  lsb-release \
  python3-rbd

exit 0
