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

# configure ntp
net add time zone "${TIMEZONE}"
net add time ntp server "${NTP_SERVERS[0]}"
net add time ntp server "${NTP_SERVERS[1]}"
net add time ntp server "${NTP_SERVERS[2]}"
net add time ntp server "${NTP_SERVERS[3]}"

# configure loopback interface
net add loopback lo ip address "${LO_ADDR}/32"

# configure management interface
net add interface eth0 vrf mgmt
net add interface eth0 ip address "${MGMT_ADDR_CIDR}"

# configure evpn tenant vrf
net add vrf "${TENANT_NAME}" vrf-table auto
net add vrf "${TENANT_NAME}" vni "${L3_VNI}"

# create l3 vni
net add vlan "${L3_VLAN}" vrf "${TENANT_NAME}"
