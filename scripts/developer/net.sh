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

case "${1}" in
prepare)
  for range in {0..4}; do
    chown "${USER}:staff" "/dev/tap${range}"
  done
  exit 0
  ;;
start)
  ifconfig bridge0 addm tap0
  for range in {1..4}; do
    ifconfig bridge1 addm "tap${range}"
  done
  exit 0
  ;;
stop)
  ifconfig bridge0 deletem tap0
  for range in {1..4}; do
    ifconfig bridge1 deletem "tap${range}"
  done
  exit 0
  ;;
cleanup)
  for range in {0..4}; do
    chown root:wheel "/dev/tap${range}"
  done
  exit 0
  ;;
*)
  echo """
Usage: $0 <command>

Commands:
  prepare Prepare the network interfaces
  start   Start the network interfaces
  stop    Stop the network interfaces
  cleanup Cleanup the network interfaces
"""
  exit 1
  ;;
esac
