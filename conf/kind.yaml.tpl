---
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: ${CLUSTER_NAME}
networking:
  ipFamily: ipv4
  apiServerAddress: ${API_ENDPOINT_ADDR}
  apiServerPort: 6443
  podSubnet: ${POD_SUBNET}
  serviceSubnet: ${SERVICE_SUBNET}
  disableDefaultCNI: ${CUSTOM_CNI}
  kubeProxyMode: ipvs
featureGates:
  UserNamespacesStatelessPodsSupport: true
nodes:
  - role: control-plane
    labels: {}
    extraMounts: []
    #  - hostPath: /var/run/docker.sock
    #    containerPath: /var/run/docker.sock
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        listenAddress: 0.0.0.0
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        listenAddress: 0.0.0.0
        protocol: TCP
