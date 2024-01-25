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
bootcmd:
  - echo "Boot Completed!!!"
  - stat -c %T -f /sys/fs/cgroup
  - k0s status
