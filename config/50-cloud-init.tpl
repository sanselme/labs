# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  version: 2
  bonds:
    internal:
      accept-ra: false
      dhcp4: false
      dhcp6: false
      mtu: 9000
      optional: true
      parameters:
        mode: balance-alb
        mii-monitor-interval: 100
      interfaces:
        - swp3
        - swp4
  bridges:
    external:
      accept-ra: false
      dhcp4: false
      dhcp6: false
      mtu: 9000
      optional: true
      addresses:
        - 192.168.11.63/24
      routes:
        - to: default
          via: 192.168.11.1
          metric: 100
      parameters:
        stp: true
        forward-delay: 4
      interfaces:
        - swp1
        - swp2
  ethernets:
    oam:
      accept-ra: false
      dhcp4: true
      dhcp6: false
      mtu: 1500
      optional: true
      set-name: oam
      dhcp4-overrides:
        route-metric: 0
      match:
        macaddress: ${OAM_MAC_ADDR}
    swp1:
      accept-ra: false
      dhcp4: false
      dhcp6: false
      mtu: 9000
      optional: true
      set-name: swp1
      match:
        macaddress: ${SWP1_MAC_ADDR}
    swp2:
      accept-ra: false
      dhcp4: false
      dhcp6: false
      mtu: 9000
      optional: true
      set-name: swp2
      match:
        macaddress: ${SWP2_MAC_ADDR}
    swp3:
      accept-ra: false
      dhcp4: false
      dhcp6: false
      mtu: 9000
      optional: true
      set-name: swp3
      match:
        macaddress: ${SWP3_MAC_ADDR}
    swp4:
      accept-ra: false
      dhcp4: false
      dhcp6: false
      mtu: 9000
      optional: true
      set-name: swp4
      match:
        macaddress: ${SWP4_MAC_ADDR}
