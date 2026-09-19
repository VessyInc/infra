locals {
  common = yamldecode(file("${path.module}/../common.yml"))
}
