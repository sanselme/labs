# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  version: 2
  bonds:
    bond0:
      dhcp4: true
      macaddress: ${BOND0_MACADDR}
      mtu: 9000
      optional: true
      parameters:
        down-delay: 0
        mii-monitor-interval: 100
        mode: balance-alb
        transmit-hash-policy: layer2
        up-delay: 0
      interfaces:
        - eth1
        - eth2
  ethernets:
      oam:
        dhcp4-overrides:
          route-metric: 0
        dhcp4: true
        mtu: 1500
        set-name: oam
        match:
            macaddress: ${OAM_MACADDR}
      eth1:
          match:
              macaddress: ${ETH1_MACADDR}
          mtu: 9000
          optional: true
          set-name: eth1
      eth2:
          match:
              macaddress: ${ETH2_MACADDR}
          mtu: 9000
          optional: true
          set-name: eth2
      swp1:
          match:
              macaddress: ${SWP1_MACADDR}
          mtu: 9000
          optional: true
          set-name: swp1
      swp2:
          match:
              macaddress: ${SWP2_MACADDR}
          mtu: 9000
          optional: true
          set-name: swp2
