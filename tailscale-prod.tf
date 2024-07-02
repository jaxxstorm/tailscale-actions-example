module "ubuntu-tailscale-prod" {
  source  = "lbrlabs/tailscale/cloudinit"
  version = "0.0.3"
  auth_key         = var.tailscale_auth_key_prod
  enable_ssh       = true
  hostname         = "subnet-router-prod"
  advertise_tags   = ["tag:production"]
  advertise_routes = [local.vpc_cidr_prod, local.vpc_cidr_shared]
}

data "aws_ami" "prod" {

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

resource "aws_security_group" "prod" {

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

resource "aws_instance" "prod" {

  provider               = aws.shared
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc-shared.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.prod.id]

  ebs_optimized = true

  user_data_base64            = sensitive(module.ubuntu-tailscale-prod.rendered)
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "lbr-subnet-router-prod"
  }
}
