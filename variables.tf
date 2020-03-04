
variable "region" {
  description = "The AWS region."
  default     = "us-east-2"
}

variable "key_name" {
  description = "The AWS key pair to use for resources. This have to be change to match your own key"
  default     = "name_key"
}

variable "private_ip" {
  description = "The private IP to use for our instances"
  type        = string
  default     = ""
}

variable "tags" {
  description = "tags for ec2 instances"
  type        = map(string)
  default     = {}
}
variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "cidr" {
  description = "The cidr  block "
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "cidr_blocks_ingress" {
  description = "list of cidr ingress block "
  type        = list
  default     = []
}

variable "cidr_blocks_egress" {
  description = "list of cidr egress block "
  type        = list
  default     = []
}

########Variables for user_data file
variable "Password" {
  type        = string
  description = "the default password for winrm connection"
  default     = ""
}

variable "ServerName" {
  type        = string
  description = "the name of the server. Example SRV-ADDS01"
  default     = ""
}

variable "TimeZoneID" {
  type        = string
  description = "the system time zone to a specified time zone."
  default     = ""
}

variable "DomainName" {
  type        = string
  description = "Specifies the fully qualified domain name (FQDN) for the root domain in the forest. "
  default     = ""
}

variable "ForestMode" {
  type        = string
  description = "Specifies the forest functional level for the new forest. "
  default     = ""
}

variable "DomainMode" {
  type        = string
  description = "Specifies the domain functional level of the first domain in the creation of a new forest. "
  default     = ""
}
variable "DatabasePath" {
  type        = string
  description = "Specifies the fully qualified, non-Universal Naming Convention (UNC) path to a directory on a fixed disk of the local computer that contains the domain database "
  default     = ""
}
variable "SYSVOLPath" {
  type        = string
  description = "Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the Sysvol file is written. "
  default     = ""
}
variable "LogPath" {
  type        = string
  description = "Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the log file for this operation is written. "
  default     = ""
}
variable "AdminSafeModePassword" {
  type        = string
  description = "Supplies the password for the administrator account when the computer is started in Safe Mode or a variant of Safe Mode, such as Directory Services Restore Mode. "
  default     = ""
}
