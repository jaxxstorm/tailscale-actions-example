module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"
  providers = {
    aws = aws.shared
  }

  name            = "tgw-shared"
  description     = "LBR labs shared transit gateway"
  amazon_side_asn = 64532

  enable_auto_accept_shared_attachments = true
  enable_multicast_support              = false

  ram_allow_external_principals = true
  ram_principals = [
    565485516070, # dev account
    780219548054 # prod account
  ]

  vpc_attachments = {
    "vpc-shared" = {
      vpc_id = module.vpc-shared.vpc_id
      subnet_ids = module.vpc-shared.intra_subnets
    }
  }

  tags = {
    Name = "tgw-shared"

  }
}

resource "aws_key_pair" "shared" {
  provider = aws.shared
  key_name = "lbriggs"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "vpc-shared" {
  providers = {
    aws = aws.shared
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name               = "tgw-shared-west"
  cidr               = local.vpc_cidr_shared
  enable_nat_gateway = true

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = local.vpc_private_subnets_shared
  public_subnets  = local.vpc_public_subnets_shared
  intra_subnets   = local.vpc_intra_subnets_shared
  
}

data "aws_route_tables" "vpc-shared" {
  provider = aws.shared
  vpc_id = module.vpc-shared.vpc_id
}

resource "aws_route" "dev" {
  provider = aws.shared
  count                     = length(local.shared_route_tables)
  route_table_id            = tolist(local.shared_route_tables)[count.index]
  destination_cidr_block    = local.vpc_cidr_dev
  transit_gateway_id        = module.tgw.ec2_transit_gateway_id
  depends_on                = [module.tgw.ec2_transit_gateway_vpc_attachment]
}

resource "aws_route" "prod" {
  provider = aws.shared
  count                     = length(local.shared_route_tables)
  route_table_id            = tolist(local.shared_route_tables)[count.index]
  destination_cidr_block    = local.vpc_cidr_prod
  transit_gateway_id        = module.tgw.ec2_transit_gateway_id
  depends_on                = [module.tgw.ec2_transit_gateway_vpc_attachment]
}

data "aws_ami" "ubuntu" {

  provider    = aws.shared
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}





