locals {
  common  = yamldecode(file("../common.yml"))
  appname = "central-kv"
}
