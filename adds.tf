provider "aws" {
  region  = var.region
  version = "~>2.0"
}

terraform {
  required_version = ">= 0.12, < 0.13"
}

# terraform s3 remote state
terraform {
  backend "s3" {
    bucket         = "tfstate-s3-presseproject"
    key            = "services/adds-servers/terraform.tfstate"
    dynamodb_table = "tfstate-db-presseproject"
    region         = "us-east-2"
    encrypt        = true
  }
}

# vpc module
module "vpc_adds-servers" {
  source               = "github.com/fopingn/terraform-aws-vpc-basic.git"
  name                 = "vpc-adds-servers"
  cidr                 = "30.0.0.0/16"
  public_subnets       = ["30.0.1.0/24"]
  private_subnets      = ["30.0.120.0/24", "30.0.121.0/24"]
  enable_dns_support   = true
  enable_dns_hostnames = true
  azs                  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  tags = {
    Owner       = "fopingn"
    Environment = "dev"
  }
  vpc_tags = {
    Name = "vpc_adds-servers"
  }
  igw_tags = {
    Name = "igw_adds-servers"
  }
  public_subnet_tags = {
    Name = "public_subnet-adds-servers"
  }
  private_subnet_tags = {
    Name = "private_subnet-adds-servers"
  }
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

  tags = {
    Terraform   = "true"
    Name        = "adds_servers"
    Owner       = "fopingn"
    Environment = "dev"
  }
}

############Instance module############

module "adds-servers" {

  source = "github.com/fopingn/terraform-aws-instance-basic.git"
  #ami and instance_type can be change to match your own
  ami           = "ami-0182e552fba672768"
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = module.vpc_adds-servers.public_subnets[0]
  #private_ip                  = module.vpc_adds-servers.private_subnets[*]
  associate_public_ip_address = true
  monitoring                  = true
  #get_password_data = true
  vpc_security_group_ids = module.adds-sg.sg_id[*]

  tags = {
    Terraform   = "true"
    Name        = "adds_servers"
    Owner       = "fopingn"
    Purpose     = "test"
    Environment = "dev"
  }

  # Only showing user data and provisioners
  user_data = data.template_file.user_data.rendered
}

# User-data
data "template_file" "user_data" {
  template = file("files/user_data.tpl")

  vars = {
    Password     = var.Password
    DomainName   = var.DomainName
    ForestMode   = var.ForestMode
    DomainMode   = var.DomainMode
    DatabasePath = var.DatabasePath
    SYSVOLPath   = var.SYSVOLPath
    LogPath      = var.LogPath
  }
}

locals {
  ssh_port     = 22
  rdp_port     = 3389
  winrm_port   = 5986
  tcp_protocol = "tcp"
}
