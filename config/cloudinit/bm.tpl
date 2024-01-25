#cloud-config
package_update: true
package_upgrade: true
users:
  - default
  - name: administrator
    gecos: Administrator
    lock_passwd: true
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC22nuKtuDt7OnWqvl1aBHlXf4eJSg1wI3Y2KFnPMw49Ir4iC8hUM611PhzoP+mNiCKfAlvYqAhURnGgtdtMeZJLFPRN80+pfxtNRYoIH+5mWvH3By0Jf3myrN86Am8mm9GBB4hUElqvEsCM/y4YKfeIfOVFEdoZr64LszkhMVsG7pJAVWlI6Uf0naw5SvN87QXHhl8PtARENDQpaUmRf+aoWj/2avh6o3AJRdUmXo4aSdKr/vSBuLgcs9vUDwQuhF2jZU1DahZ+sF0lG8RHPnVyuqLcvcJLZof1SZ7bbFwhtEKZND1vsE34ifQOUTgjaJQSNAg92z0mF2+W9DyoIr+CcxIHHzU8ftzVDWEg9y7NEBtwTVG4k1yQxm3lPX78Ty3Wm+NYDGqGWUlXEfxHT/9zHHLSpMAkWOIoBbw2Gu7qk9WN/kdao+6lBE/ON898CBB6nsEwBkP1+f+FPB8VwSimJkY49/dV/tYmEc52LI7p4zavPY/ta4VRl8xIv8WVt0=
ca_certs:
    remove-defaults: false
    trusted:
      - |
        -----BEGIN CERTIFICATE-----
        MIIDBTCCAe2gAwIBAgIEZTelvTANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdM
        QUJTIENBMB4XDTIzMTAyNDExMDg0NVoXDTI0MTAyMzExMDg0NVowEjEQMA4GA1UE
        AwwHTEFCUyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI4uBpXE
        4Jf3JWQstvoLWu5D59Ep0T3e7wzj7aWNA0mBJhQQcwL+Tc+obgKJGSvnYX2qWaOW
        VcCieTtsvH/6MnNh7kddmK0r74eEvqJ1RjgHZ/6erPm/XdQmqKQOr5cAv5ZGVBQA
        yyNQmpPr+FrWru71b1xX5gLXUYRYjb3AX7mArkQg0lRUno3Qv3oS9yl1DidlTn3N
        Mip0lQ+2zdPvHJnqqZzQG6mxRFpSGst14B7DucLaH9ym+u0SaiMjd9Uv5oej9Pl3
        cj+SpsGlsOaLmg1G3pniKt0VAwcK0MOlkHq1HrO93WYMmSwpXYn8jXwD8OBQp9I4
        tdG/hTWWBfBgmI0CAwEAAaNjMGEwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8E
        BAMCAQYwHwYDVR0jBBgwFoAUivqbFBhp6T0X2aFST0nuFtdC+vAwHQYDVR0OBBYE
        FIr6mxQYaek9F9mhUk9J7hbXQvrwMA0GCSqGSIb3DQEBCwUAA4IBAQBDBgScVvcu
        e9CVhXjOmKmIywv5k2nDogYqY4SKZCyXNz01X0I3riWAPmtUs/iZjcp5OkJ44wgm
        ABRq/a9Nfn/kPruSUINBPeV/Ey4L/RKRVJeTa2o5TrbUSL2MU373tWnit6Jx6fVU
        0HIPe4pPXk7DLkItSX0X3jvldGahLsTu9Y23IFEibq434rZpVIwxRdQCNvyvMxW0
        je02OWQZP/0a7LAnCDd4KFidOw8sCICj/lcG5cmAdbuA87C+bepn7xvIfeIYEnaC
        0EQXq6c2PkoMi2Uqlvcw2EDyOs8qJeksXSNGQuf9ySCL+MM54AT+hWnNX57mhW5z
        K3e4w1R6+oKR
        -----END CERTIFICATE-----
packages:
  - apparmor
  - ca-certificates
  - conntrack
  - curl
  - gnupg
  - ipvsadm
  - libcephfs2
  - libseccomp2
  - python3-rbd
disk_setup:
  /dev/sdd:
    layout: True
    overwrite: True
    table_type: gpt
fs_setup:
  - device: /dev/sdd
    filesystem: xfs
    partition: 1
write_files:
  - path: /etc/environment
    permissions: 644
    owner: root
    content: |
      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
      EDITOR="vim"
  - path: /usr/lib/systemd/system/user@.service.d/delegate.conf
    permissions: 644
    owner: root
    content: |
      [Service]
      Delegate=cpu cpuset io memory pids
  - path: /etc/byoh/bootstrap-kubeconfig.conf
    permissions: 644
    owner: root
    content: |
      apiVersion: v1
      clusters: []
      contexts:
      - context:
          cluster: default-cluster
          namespace: default
          user: default-auth
        name: default-context
      current-context: default-context
      kind: Config
      preferences: {}
      users: []
  - path: /usr/lib/systemd/system/var-openebs.mount
    permissions: 644
    owner: root
    content: |
      [Unit]
      Description=OpenEBS Hostpath (/var/openebs)
      DefaultDependencies=no
      Conflicts=umount.target
      Before=local-fs.target umount.target
      After=swap.target

      [Mount]
      What=/dev/disk/by-uuid/98cff45f-54b2-4431-bf41-d925620fa287
      Where=/var/openebs
      Type=xfs
      Options=defaults

      [Install]
      WantedBy=multi-user.target
  - path: /usr/lib/systemd/system/var-openebs.automount
    permissions: 644
    owner: root
    content: |
      [Unit]
      Description=OpenEBS Hostpath (/var/openebs)
      ConditionPathExists=/var/openebs

      [Automount]
      Where=/var/openebs
      TimeoutIdleSec=10

      [Install]
      WantedBy=multi-user.target
  - path: /usr/lib/systemd/system/byoh-hostagent.service
    permissions: 644
    owner: root
    content: |
      [Unit]
      Description=BYOH Host Agent
      Documentation=https://github.com/vmware-tanzu/cluster-api-provider-bringyourownhost/
      Requires=network-online.target
      After=network-online.target
      ConditionPathExists=/etc/byoh/bootstrap-kubeconfig.conf

      [Service]
      Restart=always
      RestartSec=10s
      KillMode=mixed
      Environment="NAMESPACE=depot"
      Environment="KUBECONFIG=/etc/byoh/bootstrap-kubeconfig.conf"
      Environment="LOGFILE=/var/log/byoh-hostagent.log"
      ExecStart=/bin/sh -c \
          "exec /usr/local/bin/byoh-hostagent \
            --skip-installation \
            --namespace $NAMESPACE \
            --bootstrap-kubeconfig $KUBECONFIG 2>&1 | tee -a $LOGFILE"

      [Install]
      WantedBy=multi-user.target
  - path: /usr/lib/systemd/system/byoh-hostagent-watcher.service
    permissions: 644
    owner: root
    content: |
      [Unit]
      Description=host-agent restarter
      DefaultDependencies=no
      Wants=network.target
      After=network.target

      [Service]
      Type=oneshot
      ExecStart=/usr/bin/systemctl restart byoh-hostagent.service
      TimeoutStopSec=5

      [Install]
      WantedBy=multi-user.target
  - path: /usr/lib/systemd/system/byoh-hostagent-watcher.path
    permissions: 644
    owner: root
    content: |
      [Path]
      Unit=byoh-hostagent-watcher.service
      PathChanged=/etc/byoh/bootstrap-kubeconfig.conf
      TimeoutStopSec=5

      [Install]
      WantedBy=multi-user.target
  - path: /etc/lxd/config.yaml
    permissions: 644
    owner: root
    content: |
      config:
        cluster.https_address: 192.168.11.5:8443
        # core.bgp_address=192.168.11.5:179
        # core.bgp_asn=65001
        # core.bgp_routerid=192.168.11.5
        core.https_address: 192.168.11.5:8443
        network.ovn.northbound_connection: ssl:192.168.11.5:6641
      networks: []
      storage_pools: []
      profiles:
      - config: {}
        description: ""
        devices: {}
        name: default
      projects: []
      cluster:
        server_name: sandbox
        enabled: true
        member_config: []
        cluster_address: ""
        cluster_certificate: ""
        server_address: ""
        cluster_password: ""
        cluster_certificate_path: ""
        cluster_token: ""
  - path: /etc/lxd/profile.yaml
    permissions: 644
    owner: root
    content: |
      config: {}
      description: Default LXD profile
      devices:
        oam:
          name: oam
          network: default
          type: nic
        root:
          path: /
          pool: default
          type: disk
      name: default
      used_by:
  - path: /etc/maas/ca.crt
    permissions: 644
    owner: root
    content: ""
  - path: /opt/setup-machine.sh
    permissions: 755
    owner: root
    content: |
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

      : "${LOCALE:="C.UTF-8"}"
      : "${TIMEZONE:="America/Toronto"}"

      # disable swap
      swapoff -a && sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

      # set locale
      localectl set-locale LANG="${LOCALE}"

      # set timezone
      timedatectl set-ntp true
      timedatectl set-timezone "${TIMEZONE}"

      # disable firewall
      if command -v ufw >>/dev/null; then
        ufw disable
      fi
  - path: /opt/bootstrap-microceph.sh
    permissions: 755
    owner: root
    content: |
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
      microceph cluster bootstrap

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
      # mkdir -p /var/snap/microceph/current/tls
      # cp -f /opt/tls/tls.key /var/snap/microceph/current/tls/tls.key
      # cp -f /opt/tls/tls.crt /var/snap/microceph/current/tls/tls.crt

      cat <<EOF > /var/snap/microceph/current/conf/passwd
      $(openssl rand -hex 8)
      EOF

      ceph mgr module enable dashboard
      ceph config set mgr mgr/dashboard/server_addr 192.168.11.5
      ceph config set mgr mgr/dashboard/server_port 8080
      # ceph config set mgr mgr/dashboard/ssl_server_port 8080
      # ceph config set mgr mgr/dashboard/ssl false

      # ceph dashboard set-ssl-certificate -i /var/snap/microceph/707/tls/tls.crt
      # ceph dashboard set-ssl-certificate-key -i /var/snap/microceph/707/tls/tls.key
      # ceph dashboard set-rgw-api-ssl-verify false
      ceph dashboard ac-user-create admin -i /var/snap/microceph/current/conf/passwd administrator
      ceph dashboard set-rgw-credentials

      # restart
      snap restart microceph.mgr
  - path: /opt/bootstrap-microovn.sh
    permissions: 755
    owner: root
    content: |
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

      # install microovn
      snap install microovn

      # initialize
      microovn cluster bootstrap
  - path: /opt/bootstrap-lxd.sh
    permissions: 755
    owner: root
    content: |
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

      # install latest lxd
      snap remove --purge lxd
      snap install lxd

      # init lxd with preseed
      cat /etc/lxd/config.yaml | lxd init --preseed

      # configure ovn
      lxc network create UPLINK --type=physical parent=external
      lxc network set UPLINK  \
        ipv4.ovn.ranges=192.168.11.64-192.168.11.191 \
        ipv4.gateway=192.168.11.1/24 \
        dns.nameservers=1.1.1.1,9.9.9.9
      lxc network create default --type=ovn network=UPLINK

      # configure ceph
      ceph osd pool create lxd
      ceph osd pool application enable lxd rbd

      ceph fs subvolumegroup create cephfs lxd
      ceph fs subvolumegroup getpath cephfs lxd

      # configure cephfs
      lxc storage create default ceph source=lxd
      lxc storage create shared cephfs source=cephfs/volumes/lxd

      # configure profile
      lxc profile edit default < /etc/lxd/profile.yaml

      # enable gui
      snap set lxd ui.enable=true
      sudo systemctl reload snap.lxd.daemon
      lxc config trust add --name lxd-ui

      # FIXME: register to maas
      # lxc config trust add /etc/maas/ca.crt
  - path: /opt/install-byoh-hostagen.sh
    permissions: 755
    owner: root
    content: |
      #!/bin/bash

      : "${BYOH_VERSION:=0.4.0}"
      : "${BYOH_ARCH:=$(dpkg --print-architecture)}"

      curl -fsSLo \
        /usr/local/bin/byoh-hostagent \
        "https://github.com/vmware-tanzu/cluster-api-provider-bringyourownhost/releases/download/v${BYOH_VERSION}/byoh-hostagent-linux-${BYOH_ARCH}"

      chmod +x /usr/local/bin/byoh-hostagent
runcmd:
  - /opt/setup-machine.sh
  - /opt/install-byoh-hostagen.sh
  - curl -sSLf https://get.k0s.sh | sudo sh
  - snap install microceph microovn lxd
bootcmd:
  - echo "Boot Completed!!!"
  - stat -c %T -f /sys/fs/cgroup
  - k0s status
