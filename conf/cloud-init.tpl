#cloud-config

groups: []
# - name: docker
#   system: true
#   members:
#     - ubuntu

users:
  - default
  - name: ubuntu
    gecos: Ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    lock_passwd: true
    ssh_redirect_user: true
    ssh_import_id: None
    ssh_authorized_keys: []

preserve_hostname: true
prefer_fqdn_over_hostname: true
hostname: ubuntu
fqdn: ubuntu.local

growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false

manage_resolv_conf: true
resolv_conf:
  nameservers:
    - 1.1.1.1
    - 9.9.9.9
  searchdomains: []
  # - example.com
  options:
    rotate: true
    timeout: 1

timezone: America/Toronto
ntp:
  enabled: true
  ntp_client: systemd-timesyncd
  ntp_servers:
    - 0.ubuntu.pool.ntp.org
    - 1.ubuntu.pool.ntp.org
    - 2.ubuntu.pool.ntp.org
    - 3.ubuntu.pool.ntp.org

ca_certs:
  remove-defaults: false
  trusted: []

apt:
  sources: {}
  # curtin-dev-ppa.list:
  #   source: "deb http://ppa.launchpad.net/curtin-dev/test-archive/ubuntu bionic main"
  #   keyid: F430BBA5
  #   key: ""

package_update: true
package_upgrade: true
packages: []
# - docker.io
# - docker-compose

write_files: []
# - path: /etc/hosts
#   permissions: "0644"
#   owner: root
#   content: |
#     127.0.0.1 localhost
#     ::1 localhost ip6-localhost ip6-loopback
#     ff02::1 ip6-allnodes
#     ff02::2 ip6-allrouters

bootcmd: []
# - echo "Hello World"

runcmd: []
# - echo "Hello World"
