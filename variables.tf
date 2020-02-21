
variable "region" {
  description = "The AWS region."
  default     = "us-east-2"
}

variable "key_name" {
  description = "The AWS key pair to use for resources. This have to be change to match your own key"
  default     = "name_key"
}

/*variable "instance_ips" {
  description = "The private IPs to use for our instances"
  default     = ["10.0.1.20", "10.0.1.21"]
}
*/
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

/*variable "Confirm" {
  type = bool
  description = "Prompts you for confirmation before running the cmdlet"
  default = ""
}
*/
variable "DomainName" {
  type        = string
  description = "Specifies the fully qualified domain name (FQDN) for the root domain in the forest. "
  default     = ""
}

/*variable "CreateDnsDelegation" {
  type = bool
  description = "Indicates that this cmdlet creates a DNS delegation that references the new DNS server that you install along with the domain controller."
  default = ""
}

variable "InstallDns" {
  type = bool
  default = "Indicates that this cmdlet installs and configures the DNS Server service for the new forest"
  default= false
}
*/
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
/*
variable "SkipAutoConfigureDns" {
  type = bool
  description = "Indicates that the cmdlet skips automatic configuration of DNS client settings, forwarders, and root hints. "
  default = ""
}

variable "SkipPreChecks" {
  type = bool
  description = "Indicates that the cmdlet performs only a base set of validations."
  default = ""
}
*/
