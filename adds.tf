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
      from_port   = local.internet_port
      to_port     = local.internet_port
      protocol    = local.tcp_protocol
      description = "web connection not secure"
    },
    {
      from_port   = local.https_port
      to_port     = local.https_port
      protocol    = local.tcp_protocol
      description = "web connection with ssl"
    },
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
    }
  ]

  egress = [
    {
      from_port   = local.https_port
      to_port     = local.https_port
      protocol    = local.tcp_protocol
      description = "web connection with ssl"
    },
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
    }

  ]


  cidr_blocks_ingress = ["10.20.0.0/24", "10.20.50.0/24"]

  cidr_blocks_egress = ["0.0.0.0/0"]

  tags = {
    Terraform   = "true"
    Name        = "adds_servers"
    Owner       = "fopingn"
    Purpose     = "test"
    Environment = "dev"
  }
}

############Instance module############

module "adds-servers" {

  source = "github.com/fopingn/terraform-aws-instance-basic.git"
  #ami and instance_type can be change to match your own
  ami           = "ami-0182e552fba672768"
  instance_type = "t2.micro"
  #key_name                    = var.key_name
  subnet_id = module.vpc_adds-servers.public_subnets[0]
  #private_ip                  = module.vpc_adds-servers.private_subnets[*]
  associate_public_ip_address = true
  monitoring                  = true
  #get_password_data = true
  vpc_security_group_ids = module.adds-sg.sg_id[*]

  tags = {
    Owner       = "fopingn"
    Purpose     = "test"
    Environment = "dev"
  }


  # Only showing user data and provisioners
  user_data = data.template_file.user_data.rendered

  /*  # Provisioners that use WinRM
  provisioner "file" {
    source      = "files/config.ps1"
    destination = "C:/config.ps1"

    ###Connection block
    connection {
      host     = self.public_ip
      port     = local.winrm_port
      type     = "winrm"
      user     = "terraform"
      password = var.winrm_password
      insecure = true
      https    = true
    }
  }

  provisioner "remote-exec" {
    when   = destroy
    inline = ["C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Unrestricted -File C:/config.ps1"]


    ###Connection block
    connection {
      host     = self.public_ip
      port     = local.winrm_port
      type     = "winrm"
      user     = "terraform"
      password = var.winrm_password
      insecure = true
      https    = true
    }
  }
*/
  ####################################Testing code from some blog
  # Generate a password for our WinRM connection
  /*resource "random_string" "winrm_password" {
  length = 16
  special = false
}*/



  /*resource "aws_security_group" "adds_sg" {
  name        = "adds_host"
  description = "Allow SSH & WINRM to adds hosts"
  vpc_id      = module.vpc_adds-servers.vpc_id
###Allow ssh connection
  ingress {
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
###Allow Winrm connection
  ingress {
    from_port   = local.winrm_port
    to_port     = local.winrm_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = local.all_ips
  }
}*/
}

# User-data
data "template_file" "user_data" {
  template = file("files/user_data.tpl")

  vars = {
    password          = var.winrm_password
    DomainName        = var.DomainName
    ForestMode        = var.ForestMode
    DomainMode        = var.DomainMode
    DatabasePath      = var.DatabasePath
    SYSVOLPath        = var.SYSVOLPath
    LogPath           = var.LogPath
    ADRestorePassword = var.ADRestorePassword
  }
}

locals {
  ssh_port      = 22
  winrm_port    = 5986
  https_port    = 443
  internet_port = 8080
  #any_port     = 0
  #any_protocol = "-1"
  tcp_protocol = "tcp"
  #all_ips      = ["0.0.0.0/0"]
}
