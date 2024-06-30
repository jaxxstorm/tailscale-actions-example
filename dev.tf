module "vpc-dev" {
  providers = {
    aws = aws.dev
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name               = "tgw-development-west"
  cidr               = local.vpc_cidr_dev
  enable_nat_gateway = true

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = local.vpc_private_subnets_dev
  public_subnets  = local.vpc_public_subnets_dev
  intra_subnets   = local.vpc_intra_subnets_dev

}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev" {
  provider           = aws.dev
  subnet_ids         = module.vpc-dev.intra_subnets
  transit_gateway_id = module.tgw.ec2_transit_gateway_id
  vpc_id             = module.vpc-dev.vpc_id
  tags = {
    Name = "tgw-dev"
  }
}

// add routes to transit gateway
data "aws_route_tables" "vpc-dev" {
  provider = aws.dev
  vpc_id   = module.vpc-dev.vpc_id
}

resource "aws_route" "dev-shared" {
  provider               = aws.dev
  count                  = length(local.dev_route_tables)
  route_table_id         = tolist(local.dev_route_tables)[count.index]
  destination_cidr_block = local.vpc_cidr_shared
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id
}

module "db-dev" {
  providers = {
    aws = aws.dev
  }
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "example"

  engine               = "mysql"
  engine_version       = "5.7"
  major_engine_version = "5.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  skip_final_snapshot = true

  db_name  = "example"
  username = "user"
  port     = "3306"

  vpc_security_group_ids = [aws_security_group.rds.id]

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc-dev.private_subnets

  # DB parameter group
  family = "mysql5.7"

  # Database Deletion Protection
  deletion_protection = false
}

resource "aws_security_group" "rds" {
  provider = aws.dev
  name_prefix = "rds-"
  description = "Allow inbound traffic to RDS"
  vpc_id      = module.vpc-dev.vpc_id

  ingress {
    description = "Allow inbound from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_dev]
  }

  ingress {
    description = "Allow inbound from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_shared]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

