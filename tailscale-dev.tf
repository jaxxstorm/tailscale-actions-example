module "ubuntu-tailscale-dev" {
  source           = "lbrlabs/tailscale/cloudinit"
  version          = "0.0.3"
  auth_key         = var.tailscale_auth_key_dev
  enable_ssh       = true
  hostname         = "subnet-router-dev"
  advertise_tags   = ["tag:development"]
  advertise_routes = [local.vpc_cidr_dev, local.vpc_cidr_shared]
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
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc-shared.public_subnets[0]
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
