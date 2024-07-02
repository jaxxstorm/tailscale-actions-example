output "dev_rds_endpoint" {
  value = module.db-dev.db_instance_address
}

output "prod_rds_endpoint" {
  value = module.db-prod.db_instance_address
}