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

: "${ACCESS_KEY:=$(openssl rand -hex 16)}"
: "${DISPLAY_NAME:=Synchronization User}"
: "${REALM_NAME:=microceph}"
: "${SECRET_KEY:=$(openssl rand -hex 16)}"
: "${USER_ID:=synchronization-user}"
: "${ZONE_NAME:=us-east-1}"
: "${ZONEGROUP_NAME:=us}"

ENDPOINT_URL=""

# install
snap install microceph --channel quincy
snap connect microceph:dm-crypt

# bootstrap
microceph init

# configure
microceph disk add /dev/sdb
microceph disk add /dev/sdc
microceph disk add /dev/sdd

microceph enable rgw

ceph config set mon mon_allow_pool_delete true

ceph osd pool create cephfs_data
ceph osd pool create cephfs_metadata
ceph fs new cephfs cephfs_metadata cephfs_data

# enable ssl for ceph rgw
# sed -i 's/rgw frontends = beast port=80/rgw frontends = beast ssl_port=443 ssl_certificate=\/var\/snap\/microceph\/current\/tls\/tls\.crt ssl_private_key=\/var\/snap\/microceph\/current\/tls\/tls\.key/' /var/snap/microceph/current/conf/radosgw.conf
# snap restart microceph.rgw

# configure multisite
# radosgw-admin realm create \
#   --rgw-realm "${REALM_NAME}" \
#   --default

# radosgw-admin zonegroup create \
#   --default \
#   --endpoints "${ENDPOINT_URL}" \
#   --master \
#   --rgw-realm "${REALM_NAME}" \
#   --rgw-zonegroup "${ZONEGROUP_NAME}"

# remove default zone
# radosgw-admin zonegroup delete --rgw-zonegroup default --rgw-zone default
# radosgw-admin period update --commit

# radosgw-admin zone delete --rgw-zone default
# radosgw-admin period update --commit

# radosgw-admin zonegroup delete --rgw-zonegroup default
# radosgw-admin period update --commit

# ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it
# ceph osd pool rm default.rgw.data.root default.rgw.data.root --yes-i-really-really-mean-it
# ceph osd pool rm default.rgw.gc default.rgw.gc --yes-i-really-really-mean-it
# ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
# ceph osd pool rm default.rgw.users.uid default.rgw.users.uid --yes-i-really-really-mean-it

# create system user
# radosgw-admin user create \
#   --display-name "Synchronization User" \
#   --system \
#   --uid "synchronization-user"

# radosgw-admin zone modify \
#   --access-key "${ACCESS_KEY}" \
#   --rgw-zone "${ZONE_NAME}" \
#   --secret "${SECRET_KEY}"

# radosgw-admin period update --commit

# create a realm
radosgw-admin realm create --rgw-realm "${REALM_NAME}" --default

# rename the default zonegroup and zone
radosgw-admin zonegroup rename --rgw-zonegroup default --zonegroup-new-name "${ZONEGROUP_NAME}"
radosgw-admin zone rename --rgw-zone default --zone-new-name "${ZONE_NAME}" --rgw-zonegroup "${ZONEGROUP_NAME}"

# rename the default zonegroup’s api_name
radosgw-admin zonegroup modify --api-name "${REALM_NAME}" --rgw-zonegroup "${ZONEGROUP_NAME}"

# configure the master zonegroup
radosgw-admin zonegroup modify \
  --rgw-realm "${REALM_NAME}" \
  --rgw-zonegroup "${ZONEGROUP_NAME}" \
  --endpoints "${ENDPOINT_URL}" \
  --master \
  --default

# configure the master zone
radosgw-admin zone modify \
  --rgw-realm "${REALM_NAME}" \
  --rgw-zonegroup "${ZONEGROUP_NAME}" \
  --rgw-zone "${ZONE_NAME}" \
  --endpoints "${ENDPOINT_URL}" \
  --access-key "${ACCESS_KEY}" \
  --secret "${SECRET_KEY}" \
  --master \
  --default

# create a system user
radosgw-admin user create \
  --uid "${USER_ID}" \
  --display-name "${DISPLAY_NAME}" \
  --access-key "${ACCESS_KEY}" \
  --secret "${SECRET_KEY}" \
  --system

# Commit the updated configuration:
radosgw-admin period update --commit

# restart
snap restart microceph.rgw
radosgw-admin sync status

# set orchestrator
ceph mgr module enable prometheus
ceph mgr module enable test_orchestrator
ceph orch set backend test_orchestrator

# enable dashboard
mkdir -p /var/snap/microceph/current/tls
cp -f /opt/tls/tls.key /var/snap/microceph/current/tls/tls.key
cp -f /opt/tls/tls.crt /var/snap/microceph/current/tls/tls.crt

cat <<EOF > /var/snap/microceph/current/conf/passwd
$(openssl rand -hex 8)
EOF

ceph mgr module enable dashboard
ceph config set mgr mgr/dashboard/server_addr 0.0.0.0
ceph config set mgr mgr/dashboard/server_port 8080
ceph config set mgr mgr/dashboard/ssl_server_port 8080

ceph dashboard set-ssl-certificate -i /var/snap/microceph/707/tls/tls.crt
ceph dashboard set-ssl-certificate-key -i /var/snap/microceph/707/tls/tls.key
ceph dashboard set-rgw-api-ssl-verify false
ceph dashboard ac-user-create admin -i /var/snap/microceph/current/conf/passwd administrator
ceph dashboard set-rgw-credentials

# restart
snap restart microceph.mgr
