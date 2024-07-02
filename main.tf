data "aws_caller_identity" "current" {}

locals {
  dev_route_tables = concat(
    module.vpc-dev.private_route_table_ids,
    module.vpc-dev.public_route_table_ids,
    module.vpc-dev.intra_route_table_ids
  )

  prod_route_tables = concat(
    module.vpc-prod.private_route_table_ids,
    module.vpc-prod.public_route_table_ids,
    module.vpc-prod.intra_route_table_ids
  )

  shared_route_tables = concat(
    module.vpc-shared.private_route_table_ids,
    module.vpc-shared.public_route_table_ids,
    module.vpc-shared.intra_route_table_ids
  )
}