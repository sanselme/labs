---
apiVersion: k0s.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: k0s
spec:
  api:
    # externalAddress: k0s.cluster.local
    sans:
      - k0s.cluster.local
    # extraArgs:
    #   oidc-issuer-url: <issuer-url>
    #   oidc-client-id: <client-id>
    #   oidc-username-claim: email
  extensions:
    helm:
      charts:
        - name: prometheus
          namespace: observability
          chartname: bitnami/kube-prometheus
          version: 8.18.0
          values: |
            prometheus:
              scrapeInterval: ""
              evaluationInterval: ""
        - name: cilium
          namespace: kube-system
          chartname: cilium/cilium
          version: 1.14.1
          values: |
            securityContext:
              privileged: true
            containerRuntime:
              integration: auto
            ingressController:
              enabled: true
              enforceHttps: true
              loadbalancerMode: shared
              secretsNamespace:
                create: false
                name: kube-system
            hostFirewall:
              enabled: true
            exteranlIPs:
              enabled: true
            ipam:
              mode: kubernetes
            operator:
              replicas: 1
        - name: cert-manager
          namespace: cert-manager
          chartname: jetstack/cert-manager
          version: v1.12.3
          values: |
            installCRDs: true
        - name: trust-manager
          namespace: cert-manager
          chartname: jetstack/trust-manager
          version: v0.6.0
        - name: trivy-operator
          namespace: sre
          chartname: aquasecurity/trivy-operator
          version: 0.17.0
          values: |
            operator:
              replicas: 1
        - name: flux
          namespace: sre
          chartname: bitnami/flux
          version: 0.4.0
      repositories:
        - name: aquasecurity
          url: https://aquasecurity.github.io/helm-charts/
        - name: bitnami
          url: https://charts.bitnami.com/bitnami/
        - name: cilium
          url: https://helm.cilium.io/
        - name: jetstack
          url: https://charts.jetstack.io/
    storage:
      type: openebs_local_storage
  network:
    provider: custom
    podCIDR: 10.244.0.0/16
    serviceCIDR: 10.96.0.0/12
    kubeProxy:
      disabled: false
      mode: ipvs
      ipvs:
        strictARP: true
  telemetry:
    enabled: false
