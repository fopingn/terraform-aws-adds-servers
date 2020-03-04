provider "aws" {
  region  = var.region
  version = "~>2.0"
}

terraform {
  required_version = ">= 0.12, < 0.13"
}

# terraform s3 remote state
##You have to change the different values above with your own
terraform {
  backend "s3" {
    bucket         = "tfstate-s3-presseproject"
    key            = "services/adds-servers/terraform.tfstate"
## If you use database locking
    dynamodb_table = "tfstate-db-presseproject"
    region         = "us-east-2"
    encrypt        = true
  }
}

# vpc module
module "vpc_adds-servers" {
  source               = "github.com/fopingn/terraform-aws-vpc-basic.git"
  name                 = "vpc-adds-servers"
  cidr                 = var.cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_dns_support   = true
  enable_dns_hostnames = true
  azs                  = var.azs
  tags                 = var.tags
  vpc_tags             = var.vpc_tags
  igw_tags             = var.igw_tags
  public_subnet_tags   = var.public_subnet_tags
  private_subnet_tags  = var.private_subnet_tags
}

#########Security group module
module "adds-sg" {
  source = "github.com/fopingn/terraform-aws-sg-basic.git"

  name = "adds_sg"

  description = "security group for adds instances"

  vpc_id = module.vpc_adds-servers.vpc_id

  ingress = [
    {
      from_port   = local.winrm_port
      to_port     = local.winrm_port
      protocol    = local.tcp_protocol
      description = "winrm connection"
    },
    {
      from_port   = local.ssh_port
      to_port     = local.ssh_port
      protocol    = local.tcp_protocol
      description = "ssh connection"
    },
    {
      from_port   = local.rdp_port
      to_port     = local.rdp_port
      protocol    = local.tcp_protocol
      description = "RDP connection"
    }
  ]

  egress = [
    {
      from_port   = local.winrm_port
      to_port     = local.winrm_port
      protocol    = local.tcp_protocol
      description = "winrm connection"
    },
    {
      from_port   = local.ssh_port
      to_port     = local.ssh_port
      protocol    = local.tcp_protocol
      description = "ssh connection"
    },
    {
      from_port   = local.rdp_port
      to_port     = local.rdp_port
      protocol    = local.tcp_protocol
      description = "RDP connection"
    }

  ]


  cidr_blocks_ingress = var.cidr_blocks_ingress

  cidr_blocks_egress = var.cidr_blocks_egress

  tags = var.tags
}

############Instance module############

module "adds-servers" {

  source = "github.com/fopingn/terraform-aws-instance-basic.git?ref=v0.7"
  #ami and instance_type can be change to match your own
  ami           = "ami-0182e552fba672768"
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = module.vpc_adds-servers.private_subnets[0]
  private_ip    = var.private_ip
  associate_public_ip_address = true
  monitoring                  = true
  vpc_security_group_ids = module.adds-sg.sg_id[*]
  tags = var.tags
  # Only showing user data
  user_data = data.template_file.user_data.rendered
}

# User-data
data "template_file" "user_data" {
  template = file("files/user_data.tpl")

  vars = {
    Password   = var.Password
    ServerName = var.ServerName
    private_ip = var.private_ip
    TimeZoneID            = var.TimeZoneID
    DomainName            = var.DomainName
    ForestMode            = var.ForestMode
    DomainMode            = var.DomainMode
    DatabasePath          = var.DatabasePath
    SYSVOLPath            = var.SYSVOLPath
    LogPath               = var.LogPath
    AdminSafeModePassword = var.AdminSafeModePassword
  }
}

locals {
  ssh_port     = 22
  rdp_port     = 3389
  winrm_port   = 5986
  tcp_protocol = "tcp"
}
