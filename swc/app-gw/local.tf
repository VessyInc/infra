locals {
  common  = yamldecode(file("../common.yml"))
  appname = "app-gw"

  # static private frontend IP for the Application Gateway - snet-swc-vessyinc-app-gw
  # is 10.2.0.0/16, .1-.3 are reserved by Azure
  agw_frontend_private_ip = "10.2.0.4"

  # HAProxy ingress controller's internal LoadBalancer IP (haproxy/overlays/production
  # patches/service-type.yaml pins this), reached over the peered/shared AKS node subnet
  haproxy_backend_ip = "10.0.0.7"
}
