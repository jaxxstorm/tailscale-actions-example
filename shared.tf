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
  count                     = length(data.aws_route_tables.vpc-shared.ids)
  route_table_id            = tolist(data.aws_route_tables.vpc-shared.ids)[count.index]
  destination_cidr_block    = local.vpc_cidr_dev
  transit_gateway_id        = module.tgw.ec2_transit_gateway_id
}

resource "aws_route" "prod" {
  provider = aws.shared
  count                     = length(data.aws_route_tables.vpc-shared.ids)
  route_table_id            = tolist(data.aws_route_tables.vpc-shared.ids)[count.index]
  destination_cidr_block    = local.vpc_cidr_prod
  transit_gateway_id        = module.tgw.ec2_transit_gateway_id
}

module "ubuntu-tailscale-dev" {
  source           = "git@github.com:lbrlabs/terraform-cloudinit-tailscale.git"
  auth_key         = var.tailscale_auth_key
  enable_ssh       = true
  hostname         = "subnet-router-dev"
  advertise_tags   = ["tag:development"]
  advertise_routes = [local.vpc_cidr_dev, local.vpc_cidr_shared]
}

data "aws_ami" "dev" {

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

resource "aws_security_group" "dev" {

  provider    = aws.shared
  vpc_id      = module.vpc-shared.vpc_id
  description = "Tailscale required traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Tailscale access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_instance" "dev" {

  provider               = aws.shared
  ami                    = data.aws_ami.dev.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc-shared.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.dev.id]

  ebs_optimized = true

  user_data_base64            = module.ubuntu-tailscale-dev.rendered
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "lbr-subnet-router-dev"
  }
}



