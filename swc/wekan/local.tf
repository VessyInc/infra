locals {
  common  = yamldecode(file("../common.yml"))
  appname = "wekan"
}
