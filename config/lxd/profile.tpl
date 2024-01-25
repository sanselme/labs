config:
  cloud-init.user-data: ''
  limits.cpu: '2'
  limits.memory: 8GiB
  limits.memory.swap: 'true'
  security.idmap.isolated: 'true'
  security.protection.shift: 'true'
description: Default LXD profile
devices:
  oam:
    network: default
    type: nic
  root:
    path: /
    pool: default
    size: 16GiB
    type: disk
name: default
