
variable "region" {
  description = "The AWS region."
  default     = "us-east-2"
}

##############REQUIRED variables
variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table. Must be unique in this AWS account."
  type        = string
}


variable "key_name" {
  description = "The AWS key pair to use for resources. This have to be change to match your own key"
  default     = "name_key"
}

variable "instance_ips" {
  description = "The private IPs to use for our instances"
  default     = ["10.0.1.20", "10.0.1.21"]
}
variable "winrm_password" {
  description = "the default password for winrm connection"
  default     = "Passw0rd"
}
