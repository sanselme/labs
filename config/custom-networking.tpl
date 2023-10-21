# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  version: 2
  bonds:
    bond0:
      mtu: 9000
      optional: true
      parameters:
        up-delay: 0
        down-delay: 0
        mode: balance-alb
        transmit-hash-policy: layer2
        mii-monitor-interval: 100
      interfaces:
        - eth1
        - eth2
  bridges:
    br0:
      parameters:
        stp: true
        forward-delay: 4
      interfaces:
        - swp1
    br1:
      parameters:
        stp: true
        forward-delay: 4
      interfaces:
        - swp2
  ethernets:
    lo:
      addresses: 10.20.30.1/32
    oam:
      mtu: 1500
      set-name: oam
      dhcp4: true
      dhcp4-overrides:
        route-metric: 0
      match:
          macaddress: ${OAM_MACADDR}
    eth1:
      mtu: 9000
      optional: true
      set-name: eth1
      match:
          macaddress: ${ETH1_MACADDR}
    eth2:
      mtu: 9000
      optional: true
      set-name: eth2
      match:
          macaddress: ${ETH2_MACADDR}
    swp1:
      mtu: 9000
      optional: true
      set-name: swp1
      match:
          macaddress: ${SWP1_MACADDR}
    swp2:
      mtu: 9000
      optional: true
      set-name: swp2
      match:
          macaddress: ${SWP2_MACADDR}
