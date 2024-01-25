config:
  core.https_address: ${LXD_IP_ADDR}:8443
networks: []
storage_pools: []
profiles:
- config: {}
  description: ""
  devices: {}
  name: default
projects: []
cluster:
  server_name: ${LXD_CLUSTER_NAME}
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""
  cluster_certificate_path: ""
  cluster_token: ""
