locals {
  vpc_cidr_dev  = "172.20.0.0/16"
  vpc_cidr_prod = "10.0.0.0/16"
  vpc_cidr_shared = "192.168.0.0/16"

  vpc_subnets_dev  = cidrsubnets(local.vpc_cidr_dev, 3, 3, 3, 3, 3, 3, 4, 4, 4)
  vpc_subnets_prod = cidrsubnets(local.vpc_cidr_prod, 3, 3, 3, 3, 3, 3, 4, 4, 4)
  vpc_subnets_shared = cidrsubnets(local.vpc_cidr_shared, 3, 3, 3, 3, 3, 3, 4, 4, 4)

  vpc_private_subnets_dev = slice(local.vpc_subnets_dev, 0, 3)
  vpc_public_subnets_dev  = slice(local.vpc_subnets_dev, 3, 6)
  vpc_intra_subnets_dev   = slice(local.vpc_subnets_dev, 6, 9)

  vpc_private_subnets_prod = slice(local.vpc_subnets_prod, 0, 3)
  vpc_public_subnets_prod  = slice(local.vpc_subnets_prod, 3, 6)
  vpc_intra_subnets_prod   = slice(local.vpc_subnets_prod, 6, 9)

  vpc_private_subnets_shared = slice(local.vpc_subnets_shared, 0, 3)
  vpc_public_subnets_shared  = slice(local.vpc_subnets_shared, 3, 6)
  vpc_intra_subnets_shared   = slice(local.vpc_subnets_shared, 6, 9)
}