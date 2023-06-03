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
set -eux

LO_ADDR=""
MGMT_ADDR_CIDR=""

AS_NUMBER=""
BGP_PEER_INT=""

CURRENT_DIR="$(dirname "${0}")"
source "${CURRENT_DIR}/common.sh"

# configure mp-bgp
net add bgp autonomous-system "${AS_NUMBER}"
net add bgp router-id "${LO_ADDR}"
net add bgp bestpath as-path multipath-relax
net add bgp neighbor fabric peer-group
net add bgp neighbor fabric remote-as external
net add bgp neighbor fabric capability extended-nexthop
net add bgp neighbor fabric timers 10 30
net add bgp neighbor "${BGP_PEER_INT}" interface peer-group fabric
net add bgp ipv4 unicast network "${LO_ADDR}/32"
net add bgp l2vpn evpn neighbor fabric activate
